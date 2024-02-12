Try { 
    [Void][Window]
} Catch {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Window {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
    }
"@
}

Try {
    [System.Windows.SystemParameters]
} Catch {
    Add-Type -AssemblyName System.Windows.Forms
}

function Move-CurrentWindow($x, $y, $width, $height) {
    $currentPid  = [System.Diagnostics.Process]::GetCurrentProcess().Id
    $windowHandle  = (Get-Process -Id $currentPid).MainWindowHandle
    [Void][Window]::MoveWindow($windowHandle, $x, $y, $width, $height, $True)
}

function Move-CurrentWindowLeft() {
    $primaryScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width
    $primaryScreenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height

    $x = 0
    $y = 0

    $width = $primaryScreenWidth / 2
    $height = $primaryScreenHeight

    Move-CurrentWindow $x $y $width $height
}

function Move-CurrentWindowRight() {
    $primaryScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width
    $primaryScreenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height

    $x = $primaryScreenWidth / 2
    $y = 0

    $width = $primaryScreenWidth / 2
    $height = $primaryScreenHeight

    Move-CurrentWindow $x $y $width $height
}