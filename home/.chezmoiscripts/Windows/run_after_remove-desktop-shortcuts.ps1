param([switch]$Debug)

if ($Debug -or $env:DOTDEBUG) {
  $DebugPreference = "Continue"
  Start-Transcript -Path "$env:USERPROFILE\remove-desktop-shortcuts.log" -IncludeInvocationHeader
}
Write-Debug "Running $PSCommandPath"
pause
Write-Debug "Removing desktop shortcuts..."
$userDesktopPath = [System.Environment]::GetFolderPath("Desktop")
$desktopItems = Get-ChildItem -Path $userDesktopPath

if ($desktopItems.Count -eq 0) {
  Write-Debug "No desktop items found, exiting..."
  exit
}

$shortcuts = $desktopItems | Where-Object { $_.Extension -eq '.lnk' }

foreach ($shortcut in $shortcuts) {
  Write-Debug "Removing shortcut: $($shortcut.FullName)"
  Remove-Item $shortcut -Force
}

$desktopItems = Get-ChildItem -Path $userDesktopPath

$downloadsFolderPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

if ($desktopItems.Count -ne 0) {
  Write-Host 'Moving files on desktop to Downloads folder...' -ForegroundColor Yellow
  $desktopItems | Move-Item -Destination $downloadsFolderPath -Force
}

Write-Debug "Removing all users desktop shortcuts if bootstrapping..."
if ($env:BOOTSTRAPPING) {
  $allUsersScriptblock = {
    $publicDesktopPath = [System.Environment]::GetFolderPath('"CommonDesktopDirectory"')
    $shortcuts = Get-ChildItem -Path $publicDesktopPath -Filter *.lnk
    foreach ($shortcut in $shortcuts) {
      Write-Debug "Removing shortcut: $($shortcut.FullName)"
      Remove-Item $shortcut.FullName -Force
    }
  }
  Start-Process pwsh -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -Command & { $allUsersScriptblock }" 
}

Write-Debug "Refreshing explorer..."
$refreshcode = @'
private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
private const int WM_SETTINGCHANGE = 0x1a;
private const int SMTO_ABORTIFHUNG = 0x0002;
 
[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
 static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, UIntPtr wParam,
   IntPtr lParam);
 
[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)]
  private static extern IntPtr SendMessageTimeout ( IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult );
 
[System.Runtime.InteropServices.DllImport("Shell32.dll")]
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
 
public static void Refresh() {
    SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
}
'@
Add-Type -MemberDefinition $refreshcode -Namespace MyWinAPI -Name Explorer
[MyWinAPI.Explorer]::Refresh()
