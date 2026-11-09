param(
    [string] $BuildDirectory = 'Ardour-9.7.0\build-msvc-vsenv',
    [string] $DependencyDirectory = 'depstack\release\bin',
    [string] $OutputDirectory = 'release'
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$buildRoot = Join-Path $repoRoot $BuildDirectory
$dependencyBin = Join-Path $repoRoot $DependencyDirectory
$ardourRoot = Join-Path $repoRoot 'Ardour-9.7.0'
$stageRoot = Join-Path $repoRoot '.package-stage'
$payloadRoot = Join-Path $stageRoot 'Hub Studio'
$outputRoot = Join-Path $repoRoot $OutputDirectory
$payloadZip = Join-Path $stageRoot 'Hub-Studio-Windows-x64-app.zip'
$installer = Join-Path $outputRoot 'Hub-Studio-Windows-x64-Setup.exe'

if (-not (Test-Path -LiteralPath (Join-Path $buildRoot 'gtk2_ardour\ardour-9.7.0.exe'))) {
    throw "Build Ardour absent: $(Join-Path $buildRoot 'gtk2_ardour\ardour-9.7.0.exe')"
}
if (-not (Test-Path -LiteralPath $dependencyBin)) {
    throw "Dependances MSVC absentes: $dependencyBin"
}
$compiler = @(
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $compiler) { throw 'Le compilateur C# du .NET Framework est requis pour fabriquer Setup.exe.' }

New-Item -ItemType Directory -Force -Path $stageRoot, $outputRoot | Out-Null
if (Test-Path -LiteralPath $payloadRoot) {
    Remove-Item -LiteralPath $payloadRoot -Recurse -Force
}
$binRoot = Join-Path $payloadRoot 'bin'
$libRoot = Join-Path $payloadRoot 'lib'
$uiRoot = Join-Path $payloadRoot 'ui'
$shareRoot = Join-Path $payloadRoot 'share'
New-Item -ItemType Directory -Force -Path $binRoot, $libRoot, $uiRoot, $shareRoot | Out-Null

Copy-Item -LiteralPath (Join-Path $buildRoot 'gtk2_ardour\ardour-9.7.0.exe') -Destination $binRoot
Get-ChildItem -LiteralPath $dependencyBin -File | Where-Object { $_.Extension -in '.dll', '.exe' } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $binRoot -Force
}

# Keep the runtime layout of Ardour's libraries and plugins while omitting
# compiler objects, import libraries, headers, and other build-only outputs.
$runtimeExtensions = @('.dll', '.exe', '.manifest', '.ttl')
Get-ChildItem -LiteralPath (Join-Path $buildRoot 'libs') -Recurse -File |
    Where-Object { $runtimeExtensions -contains $_.Extension.ToLowerInvariant() } |
    ForEach-Object {
        $relative = [IO.Path]::GetRelativePath((Join-Path $buildRoot 'libs'), $_.FullName)
        $destination = Join-Path $libRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    }

# Ardour reads its UI definitions from gtk2_ardour and its runtime data from share.
$uiSource = Join-Path $ardourRoot 'gtk2_ardour'
$uiExtensions = @('.rc', '.conf', '.xml', '.keys', '.menus', '.png', '.ico', '.svg', '.xpm', '.ui', '.css', '.json', '.txt', '.mo', '.xml.in')
Get-ChildItem -LiteralPath $uiSource -Recurse -File |
    Where-Object { $uiExtensions -contains $_.Extension.ToLowerInvariant() } |
    ForEach-Object {
        $relative = [IO.Path]::GetRelativePath($uiSource, $_.FullName)
        $destination = Join-Path $uiRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    }
Copy-Item -Path (Join-Path $ardourRoot 'share\*') -Destination $shareRoot -Recurse -Force
Copy-Item -LiteralPath (Join-Path $ardourRoot 'COPYING') -Destination $payloadRoot
Copy-Item -LiteralPath (Join-Path $repoRoot 'GUIDE_ARDOUR_FR.md') -Destination $payloadRoot -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $repoRoot 'HUB_STUDIO.md') -Destination $payloadRoot -ErrorAction SilentlyContinue

$launcher = @'
$ErrorActionPreference = 'Stop'
$appRoot = $PSScriptRoot
$binRoot = Join-Path $appRoot 'bin'
$libRoot = Join-Path $appRoot 'lib'
$env:PATH = "$binRoot;$env:PATH"
$env:ARDOUR_DLL_PATH = $libRoot
$env:ARDOUR_BACKEND_PATH = @(
    (Join-Path $libRoot 'backends\dummy'),
    (Join-Path $libRoot 'backends\jack'),
    (Join-Path $libRoot 'backends\portaudio')
) -join ';'
$env:ARDOUR_DATA_PATH = @((Join-Path $appRoot 'ui'), (Join-Path $appRoot 'share')) -join ';'
$env:ARDOUR_CONFIG_PATH = Join-Path $appRoot 'ui'
Set-Location $binRoot
& (Join-Path $binRoot 'ardour-9.7.0.exe') @args
'@
Set-Content -LiteralPath (Join-Path $payloadRoot 'Start-Hub-Studio.ps1') -Value $launcher -Encoding UTF8

$removeScript = @'
$ErrorActionPreference = 'Stop'
$installRoot = Join-Path $env:LOCALAPPDATA 'Programs\Hub Studio'
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Hub Studio'
Remove-Item -LiteralPath $startMenu -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $installRoot -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\HubStudio' -Recurse -Force -ErrorAction SilentlyContinue
'@
Set-Content -LiteralPath (Join-Path $payloadRoot 'Uninstall-Hub-Studio.ps1') -Value $removeScript -Encoding UTF8

if (Test-Path -LiteralPath $payloadZip) { Remove-Item -LiteralPath $payloadZip -Force }
Compress-Archive -LiteralPath (Join-Path $stageRoot 'Hub Studio') -DestinationPath $payloadZip -CompressionLevel Optimal

if (Test-Path -LiteralPath $installer) { Remove-Item -LiteralPath $installer -Force }
$compilerArguments = @(
    '/nologo', '/target:winexe', "/out:$installer",
    '/reference:System.Windows.Forms.dll',
    '/reference:System.IO.Compression.dll',
    '/reference:System.IO.Compression.FileSystem.dll',
    "/resource:$payloadZip,HubStudio.Payload.zip",
    (Join-Path $repoRoot 'HubStudioSetup.cs')
)
& $compiler @compilerArguments
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installer)) {
    throw "Le compilateur C# n'a pas genere Setup.exe. Code: $LASTEXITCODE"
}

$installerInfo = Get-Item -LiteralPath $installer
Write-Host "Installateur cree: $($installerInfo.FullName)"
Write-Host "Taille: $([math]::Round($installerInfo.Length / 1MB, 1)) Mo"
