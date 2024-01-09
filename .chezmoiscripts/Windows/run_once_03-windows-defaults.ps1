Write-Host "Applying Windows defaults..." -ForegroundColor DarkYellow
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait -WindowStyle Hidden
  exit
}

$defaults = @(
  # Disable Startup Sound
  @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"; Name = "DisableStartupSound"; Value = 1 }
  @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation"; Name = "DisableStartupSound"; Value = 1 }

  # Set the sound scheme to 'No Sounds'
  @{Path = "HKCU:\AppEvents\Schemes"; Name = "(Default)"; Value = ".None" }

  # Set dark mode and accent color "Storm"
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "AppsUseLightTheme"; Value = 0 }
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "SystemUsesLightTheme"; Value = 0 }
  @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "AccentColor"; Value = "0xff484a4c" }
  @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "ColorizationColor"; Value = "0xc44c4a48" }
  @{Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "ColorizationAfterglow"; Value = "0xc44c4a48" }
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"; Name = "AccentColorMenu"; Value = "0xff484a4c" }
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"; Name = "AccentPalette"; Value = [byte[]]("9B,9A,99,00,84,83,81,00,6D,6B,6A,00,4C,4A,48,00,36,35,33,00,26,25,24,00,19,19,19,00,10,7C,10,00".Split(',') | ForEach-Object { "0x$_" }) }
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"; Name = "StartColorMenu"; Value = "0xff2a2ab8" }
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "ColorPrevalence"; Value = 1 }

  # Hide Taskbar search box, task view button, widgets and chat (takes effect after reboot)
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "SearchboxTaskbarMode"; Value = 0 } # Searchbox
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTaskViewButton"; Value = 0 } # Task button
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarDa"; Value = 0 }
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarMn"; Value = 0 }

  # Hide News and Interests from taskbar
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"; Name = "ShellFeedsTaskbarViewMode"; Value = 2 }
  
  # Hide Recently Added Apps from Start Menu
  @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name = "HideRecentlyAddedApps"; Value = 1 }

  # Hide recently added and frequently used from Quick Access in Explorer
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowRecent"; Value = 0 }
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowFrequent"; Value = 0 }


  # Disable sticky keys by hitting shift 5 times shortcut
  @{Path = "HKCU:\Control Panel\Accessibility\StickyKeys"; Name = "Flags"; Value = 506 }

  # Disable Whats New in Windows
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"; Name = "ScoobeSystemSettingEnabled"; Value = 0 }

  # Hide App suggestions from Start Menu
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SubscribedContent-338388Enabled"; Value = 0 }

  # Show file extensions
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideFileExt"; Value = 0 }

  # Show path in title bar
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"; Name = "FullPath"; Value = 1 }

  # Disable creating Thumbs.db files on network folders
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "DisableThumbnailsOnNetworkFolders"; Value = 1 }

  # Disable file deletion confirmation dialog
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "ConfirmFileDelete"; Value = 0 }
  
  # Turn Off Windows Narrator Hotkey
  @{Path = "HKCU:\SOFTWARE\Microsoft\Narrator\NoRoam"; Name = "WinEnterLaunchEnabled"; Value = 0 }

  # Disable Edge pre-launching
  @{Path = "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main"; Name = "AllowPrelaunch"; Value = 0 }

  # Disable Windows Meet Now
  @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "HideSCAMeetNow"; Value = 1 }



)


foreach ($setting in $defaults) {
  if (!(Test-Path -Path $setting.Path)) {
    Write-Host "Creating registry path: $($setting.Path)"
    New-Item $setting.Path -Force | Out-Null
  }
  else {
    Set-ItemProperty @setting
  }
}

# Clear all current applied system sounds
Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" | Get-ChildItem | Get-ChildItem | Where-Object { $_.PSChildName -eq ".Current" } | Set-ItemProperty -Name "(Default)" -Value ""


# Apply the changes
rundll32.exe user32.dll, UpdatePerUserSystemParameters
