# Hub Studio Windows installer

The Windows x64 installer is a per-user Setup application. It installs Ardour
9.7 and the Hub session starter scripts under
`%LOCALAPPDATA%\Programs\Hub Studio`, creates Start menu and desktop
shortcuts, and adds an entry to Windows' installed-apps list. Administrator
rights are not required.

## Build the installer

First build Ardour with the MSVC workflow and make sure the matching xmake
dependency stack exists in `depstack\release\bin`. From the repository root,
run:

```powershell
 powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\package-hub-studio-windows.ps1
```

The script stages only runtime DLLs, executables, plugin files, Ardour data,
and the Hub templates; compiler object files are omitted. The resulting
downloadable installer is:

```text
release\Hub-Studio-Windows-x64-Setup.exe
```

The setup contains a compressed runtime payload and a small Windows installer
program. To distribute it, attach this `.exe` to a GitHub Release. Do not add
the generated payload or build directories to the source commit.

## Notes

- This is an experimental Windows x64 build based on Ardour 9.7.
- The installer is currently unsigned, so Windows SmartScreen may show its
  standard warning for a new application publisher.
- The installer needs the .NET Framework 4.8 runtime and the Microsoft Visual
  C++ 2015-2022 Redistributable (x64). Windows 10/11 normally already have the
  .NET Framework; install the VC++ runtime from
  [Microsoft's official download page](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
  if Ardour reports a missing runtime DLL.
- The bundled `COPYING` file and third-party license notices are included with
  the application. Review upstream component terms before redistributing any
  additional plugins.
