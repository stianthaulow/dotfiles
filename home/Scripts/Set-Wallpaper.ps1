. (Join-Path $PSScriptRoot "Util.ps1")

$themePath = "$env:USERPROFILE\Theme"

if (-not (Test-Path $themePath)) {
  Write-Log "Theme folder not found"
  exit
}

$wallpaperPath = "$themePath\Wallpaper\wallpaper.jpg"

$setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
  public const int SetDesktopWallpaper = 20;
  public const int UpdateIniFile = 0x01;
  public const int SendWinIniChange = 0x02;
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  public static void SetWallpaper(string path)
  {
    SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
  }
}
"@
Add-Type -TypeDefinition $setwallpapersrc
Write-Log "Setting wallpaper to $wallpaperPath"
[Wallpaper]::SetWallpaper($wallpaperPath)