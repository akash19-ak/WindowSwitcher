
# Smart Window Switcher
# Windows PowerShell - no AutoHotkey required

$MoodleUrl  = "https://slms.ssodl.edu.in/"
$WingspanUrl = "https://ssodl.onwingspan.com/"

Add-Type -TypeDefinition @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public class SmartWindowSwitcher
{
    private const int MOD_ALT = 0x0001;
    private const int MOD_CONTROL = 0x0002;
    private const int WM_HOTKEY = 0x0312;
    private const int SW_RESTORE = 9;

    private const uint PROCESS_QUERY_LIMITED_INFORMATION = 0x1000;

    [DllImport("user32.dll")]
    private static extern bool RegisterHotKey(
        IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    [DllImport("user32.dll")]
    private static extern int GetMessage(
        out MSG lpMsg, IntPtr hWnd, uint min, uint max);

    [DllImport("user32.dll")]
    private static extern bool TranslateMessage(ref MSG msg);

    [DllImport("user32.dll")]
    private static extern IntPtr DispatchMessage(ref MSG msg);

    [DllImport("user32.dll")]
    private static extern bool EnumWindows(
        EnumWindowsProc callback, IntPtr extra);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(
        IntPtr hWnd, StringBuilder text, int maxCount);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern bool ShowWindow(IntPtr hWnd, int cmd);

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(
        IntPtr hWnd, out uint processId);

    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr extra);

    [StructLayout(LayoutKind.Sequential)]
    private struct MSG
    {
        public IntPtr hWnd;
        public uint message;
        public UIntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public int ptX;
        public int ptY;
    }

    public static string MoodleUrl = "";
    public static string WingspanUrl = "";

    private static IntPtr FindWindow(string titleWord, string processName)
    {
        IntPtr found = IntPtr.Zero;

        EnumWindows(delegate(IntPtr hWnd, IntPtr extra)
        {
            if (!IsWindowVisible(hWnd))
                return true;

            StringBuilder title = new StringBuilder(1024);
            GetWindowText(hWnd, title, title.Capacity);
            string windowTitle = title.ToString();

            if (String.IsNullOrWhiteSpace(windowTitle))
                return true;

            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);

            try
            {
                Process p = Process.GetProcessById((int)pid);

                bool titleMatches =
                    !String.IsNullOrEmpty(titleWord) &&
                    windowTitle.IndexOf(
                        titleWord, StringComparison.OrdinalIgnoreCase) >= 0;

                bool processMatches =
                    !String.IsNullOrEmpty(processName) &&
                    String.Equals(
                        p.ProcessName, processName,
                        StringComparison.OrdinalIgnoreCase);

                bool matches = !String.IsNullOrEmpty(titleWord)
    ? titleMatches && (String.IsNullOrEmpty(processName) || processMatches)
    : processMatches;

if (matches)
                {
                    found = hWnd;
                    return false;
                }
            }
            catch { }

            return true;
        }, IntPtr.Zero);

        return found;
    }

    private static void ActivateOrLaunch(
        string titleWord, string processName, string launchTarget,
        bool isUrl)
    {
        IntPtr hWnd = FindWindow(titleWord, processName);

        if (hWnd != IntPtr.Zero)
        {
            ShowWindow(hWnd, SW_RESTORE);
            SetForegroundWindow(hWnd);
            return;
        }

        try
        {
            if (isUrl)
            {
                Process.Start(new ProcessStartInfo {
                    FileName = launchTarget,
                    UseShellExecute = true
                });
            }
            else
            {
                Process.Start(new ProcessStartInfo {
                    FileName = launchTarget,
                    UseShellExecute = true
                });
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Could not launch " + launchTarget +
                              ": " + ex.Message);
        }
    }

    private static void HandleHotkey(int id)
    {
        switch (id)
        {
            case 1:
                ActivateOrLaunch("", "chrome", "chrome.exe", false);
                break;

            case 2:
                IntPtr moodle = FindWindow("Moodle", "chrome");
                if (moodle == IntPtr.Zero)
                    moodle = FindWindow("SLMS", "chrome");

                if (moodle != IntPtr.Zero)
                {
                    ShowWindow(moodle, SW_RESTORE);
                    SetForegroundWindow(moodle);
                }
                else
                {
                    ActivateOrLaunch("", "", MoodleUrl, true);
                }
                break;

            case 3:
                IntPtr wingspan = FindWindow("Wingspan", "chrome");

                if (wingspan != IntPtr.Zero)
                {
                    ShowWindow(wingspan, SW_RESTORE);
                    SetForegroundWindow(wingspan);
                }
                else if (!String.IsNullOrWhiteSpace(WingspanUrl) &&
                         !WingspanUrl.Contains("PASTE_YOUR_"))
                {
                    ActivateOrLaunch("", "", WingspanUrl, true);
                }
                else
                {
                    Console.WriteLine(
                        "Add your actual Wingspan URL to the script.");
                }
                break;

            case 4:
                ActivateOrLaunch("", "EXCEL", "excel.exe", false);
                break;

            case 5:
                ActivateOrLaunch("", "notepad", "notepad.exe", false);
                break;
        }
    }

    public static void Run()
    {
        int[] ids = { 1, 2, 3, 4, 5 };
        uint[] keys = { 0x43, 0x4D, 0x57, 0x45, 0x4E };
        string[] names = {
            "Chrome", "Moodle", "Wingspan", "Excel", "Notepad"
        };

        Console.WriteLine("Smart Window Switcher is running.");
        Console.WriteLine("Press Ctrl+C here to stop it.");

        for (int i = 0; i < ids.Length; i++)
        {
            bool ok = RegisterHotKey(
                IntPtr.Zero, ids[i], MOD_CONTROL | MOD_ALT, keys[i]);

            Console.WriteLine(names[i] + ": " +
                (ok ? "Ctrl+Alt+" + (char)keys[i] + " ready"
                    : "Shortcut unavailable; it may already be in use."));
        }

        MSG msg;
        try
        {
            while (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0)
            {
                if (msg.message == WM_HOTKEY)
                    HandleHotkey((int)msg.wParam.ToUInt32());
                else
                {
                    TranslateMessage(ref msg);
                    DispatchMessage(ref msg);
                }
            }
        }
        finally
        {
            foreach (int id in ids)
                UnregisterHotKey(IntPtr.Zero, id);
        }
    }
}
'@

[SmartWindowSwitcher]::MoodleUrl = $MoodleUrl
[SmartWindowSwitcher]::WingspanUrl = $WingspanUrl

[SmartWindowSwitcher]::Run()