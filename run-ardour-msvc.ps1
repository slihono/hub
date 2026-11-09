param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $ArdourArguments
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$ardourRoot = Join-Path $repoRoot 'Ardour-9.7.0'
$buildRoot = Join-Path $ardourRoot 'build-msvc-vsenv'
$executable = Join-Path $buildRoot 'gtk2_ardour\ardour-9.7.0.exe'
$dependencyBin = Join-Path $repoRoot 'depstack\release\bin'
$sourceUi = Join-Path $ardourRoot 'gtk2_ardour'
$buildUi = Join-Path $buildRoot 'gtk2_ardour'

if (-not (Test-Path -LiteralPath $executable)) {
    throw "Ardour n’est pas compilé à l’emplacement attendu : $executable"
}

$dllDirectories = @($buildRoot)
$dllDirectories += Join-Path $buildRoot 'libs\fst'
$dllDirectories += Get-ChildItem -LiteralPath $buildRoot -Directory -Recurse |
    Where-Object {
        Get-ChildItem -LiteralPath $_.FullName -Filter '*.dll' -File -ErrorAction SilentlyContinue |
            Select-Object -First 1
    } |
    ForEach-Object { $_.FullName }

if (Test-Path -LiteralPath $dependencyBin) {
    $dllDirectories += $dependencyBin
}

$dllDirectories = $dllDirectories | Select-Object -Unique
$env:PATH = ($dllDirectories -join ';') + ';' + $env:PATH
$env:ARDOUR_DLL_PATH = Join-Path $buildRoot 'libs'
$env:ARDOUR_BACKEND_PATH = @(
    (Join-Path $buildRoot 'libs\backends\dummy'),
    (Join-Path $buildRoot 'libs\backends\jack'),
    (Join-Path $buildRoot 'libs\backends\portaudio')
) -join ';'
$env:ARDOUR_DATA_PATH = @($sourceUi, (Join-Path $ardourRoot 'share')) -join ';'
$env:ARDOUR_CONFIG_PATH = @($buildUi, $sourceUi) -join ';'

Push-Location (Split-Path -Parent $executable)
try {
    $startOptions = @{
        FilePath = $executable
        WorkingDirectory = (Split-Path -Parent $executable)
        PassThru = $true
        RedirectStandardOutput = (Join-Path $env:TEMP 'ardour-startup.stdout.log')
        RedirectStandardError = (Join-Path $env:TEMP 'ardour-startup.stderr.log')
    }
    if ($ArdourArguments -and $ArdourArguments.Count -gt 0) {
        $startOptions.ArgumentList = $ArdourArguments
    }
    $process = Start-Process @startOptions

    Start-Sleep -Seconds 3
    $process.Refresh()
    if ($process.HasExited) {
        Write-Host "Ardour s'est ferme au demarrage (code $($process.ExitCode))."
        Write-Host "Journal stdout : $env:TEMP\ardour-startup.stdout.log"
        Write-Host "Journal stderr : $env:TEMP\ardour-startup.stderr.log"
        foreach ($log in @((Join-Path $env:TEMP 'ardour-startup.stdout.log'), (Join-Path $env:TEMP 'ardour-startup.stderr.log'))) {
            if (Test-Path -LiteralPath $log) {
                Get-Content -LiteralPath $log -Tail 60
            }
        }
        exit $process.ExitCode
    }

    Write-Host "Ardour est lance (PID $($process.Id)). Sa fenetre devrait etre visible."
    Write-Host "Journaux temporaires : $env:TEMP\ardour-startup.stdout.log et ardour-startup.stderr.log"
}
finally {
    Pop-Location
}
