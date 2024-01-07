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
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "ShowTaskViewButton"; Value = 0 } # Task button
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarDa"; Value = 0 }
  @{Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarMn"; Value = 0 }

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



)


foreach ($setting in $defaults) {
  if (Test-Path -Path $setting.Path) {
    Set-ItemProperty @setting
  }
}

# Clear all current applied system sounds
Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" | Get-ChildItem | Get-ChildItem | Where-Object { $_.PSChildName -eq ".Current" } | Set-ItemProperty -Name "(Default)" -Value ""


# Apply the changes
rundll32.exe user32.dll, UpdatePerUserSystemParameters


# Unpit 

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

$layoutFile = "C:\Windows\StartMenuLayout.xml"

#Delete layout file if it already exists
If (Test-Path $layoutFile) {
    Remove-Item $layoutFile
}

#Creates the blank layout file
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases) {
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF (!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer" | Out-Null
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases) {
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer and delete the layout file
Stop-Process -name explorer

# Uncomment the next line to make clean start menu default for all new users
#Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

Remove-Item $layoutFile

Write-Host "Start menu layout applied." -ForegroundColor Green