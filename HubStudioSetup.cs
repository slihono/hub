using System;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Microsoft.Win32;

internal static class HubStudioSetup
{
    [STAThread]
    private static int Main()
    {
        string programs = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Programs");
        string installRoot = Path.Combine(programs, "Hub Studio");
        DialogResult choice = MessageBox.Show(
            "Install Hub Studio (Ardour 9.7) for this Windows account?\n\n" + installRoot +
            "\n\nThe installer does not require administrator rights.",
            "Hub Studio Setup", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
        if (choice != DialogResult.OK) return 0;

        string tempRoot = Path.Combine(Path.GetTempPath(), "hub-studio-setup-" + Guid.NewGuid().ToString("N"));
        try
        {
            Directory.CreateDirectory(programs);
            Directory.CreateDirectory(tempRoot);
            string archive = Path.Combine(tempRoot, "Hub-Studio-Windows-x64-app.zip");
            using (Stream payload = Assembly.GetExecutingAssembly().GetManifestResourceStream("HubStudio.Payload.zip"))
            {
                if (payload == null) throw new InvalidOperationException("The application payload is missing from this setup file.");
                using (FileStream output = File.Create(archive)) payload.CopyTo(output);
            }

            if (Directory.Exists(installRoot)) Directory.Delete(installRoot, true);
            ZipFile.ExtractToDirectory(archive, programs);
            CreateShortcuts(installRoot);
            RegisterUninstaller(installRoot);
            MessageBox.Show("Hub Studio has been installed. Start it from the desktop or Start menu.",
                "Hub Studio Setup", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return 0;
        }
        catch (Exception error)
        {
            MessageBox.Show("Hub Studio could not be installed.\n\n" + error.Message,
                "Hub Studio Setup", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
        finally
        {
            try { if (Directory.Exists(tempRoot)) Directory.Delete(tempRoot, true); }
            catch { }
        }
    }

    private static void CreateShortcuts(string installRoot)
    {
        string startMenu = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "Microsoft", "Windows", "Start Menu", "Programs", "Hub Studio");
        Directory.CreateDirectory(startMenu);
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        if (shellType == null) throw new InvalidOperationException("Windows Script Host is unavailable; shortcuts could not be created.");
        dynamic shell = Activator.CreateInstance(shellType);
        string powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),
            "WindowsPowerShell", "v1.0", "powershell.exe");
        string launcher = Path.Combine(installRoot, "Start-Hub-Studio.ps1");
        string arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + launcher + "\"";
        CreateShortcut(shell, Path.Combine(startMenu, "Hub Studio.lnk"), powershell, arguments, installRoot);
        CreateShortcut(shell, Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory),
            "Hub Studio.lnk"), powershell, arguments, installRoot);
        Marshal.FinalReleaseComObject(shell);
    }

    private static void CreateShortcut(dynamic shell, string path, string target, string arguments, string workingDirectory)
    {
        dynamic shortcut = shell.CreateShortcut(path);
        shortcut.TargetPath = target;
        shortcut.Arguments = arguments;
        shortcut.WorkingDirectory = workingDirectory;
        shortcut.Description = "Hub Studio audio workstation";
        shortcut.Save();
        Marshal.FinalReleaseComObject(shortcut);
    }

    private static void RegisterUninstaller(string installRoot)
    {
        using (RegistryKey key = Registry.CurrentUser.CreateSubKey(
            @"Software\Microsoft\Windows\CurrentVersion\Uninstall\HubStudio"))
        {
            key.SetValue("DisplayName", "Hub Studio (Ardour 9.7)");
            key.SetValue("DisplayVersion", "0.1.0");
            key.SetValue("InstallLocation", installRoot);
            string powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),
                "WindowsPowerShell", "v1.0", "powershell.exe");
            string uninstaller = Path.Combine(installRoot, "Uninstall-Hub-Studio.ps1");
            key.SetValue("UninstallString", "\"" + powershell + "\" -NoProfile -ExecutionPolicy Bypass -File \"" + uninstaller + "\"");
        }
    }
}
