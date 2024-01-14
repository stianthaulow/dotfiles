$localResourcePath = "$env:USERPROFILE\Resources"
$wallpaperPath = "$localResourcePath\Wallpaper\wallpaper.jpg"

# If wallpaper exists, assume resources have been setup
if (Test-Path -Path $wallpaperPath) {
  exit
}

Write-Host "Setting up resources..."

Connect-MgGraph -Scopes "Files.Read.All" -NoWelcome

Write-Host "Downloading resources from OneDrive..."

$drive = Get-MgDrive | Where-Object { $_.DriveType -eq "personal" }
$ResourcesItem = Get-MgDriveRootChild -DriveId $drive.Id | Where-Object { $_.Name -eq "Resources" }

$ResourcesChildren = Get-MgDriveItemChild -DriveId $drive.Id -DriveItemId $ResourcesItem.Id

$IconsItem = $ResourcesChildren | Where-Object { $_.Name -eq "Icons" }
$WallpaperItem = $ResourcesChildren | Where-Object { $_.Name -eq "Wallpaper" }

$WallpaperChildren = Get-MgDriveItemChild -DriveId $drive.Id -DriveItemId $WallpaperItem.Id
$FolderIconsItem = Get-MgDriveItemChild -DriveId $drive.Id -DriveItemId $IconsItem.Id | Where-Object { $_.Name -eq "Folders" }
$FolderIconsChildren = Get-MgDriveItemChild -DriveId $drive.Id -DriveItemId $FolderIconsItem.Id

$WallpaperFileItem = $WallpaperChildren | Where-Object { $_.Name -eq "wallpaper.jpg" }
$LoginFileItem = $WallpaperChildren | Where-Object { $_.Name -eq "login.jpg" }

Write-Host "Downloading wallpaper..."
$wallpaperPath = "$localResourcePath\Wallpaper\wallpaper.jpg"
Get-MgDriveItemContent -DriveId $drive.Id -DriveItemId $WallpaperFileItem.Id -OutFile $wallpaperPath

Write-Host "Downloading login wallpaper..."
$loginImagePath = "$localResourcePath\Wallpaper\login.jpg"
Get-MgDriveItemContent -DriveId $drive.Id -DriveItemId $LoginFileItem.Id -OutFile $loginImagePath


# Folder icons
$folders = @(
  @{Path = "$localResourcePath"; IconName = "Misc.ico" }
  @{Path = "$localResourcePath\Avatar"; IconName = "avatar.ico" }
  @{Path = "$localResourcePath\Icons"; IconName = "icons.ico" }
  @{Path = "$localResourcePath\Wallpaper"; IconName = "wallpaper.ico" }
  @{Path = "C:\Tools"; IconName = "SQL.ico" }
  @{Path = "C:\Dev"; IconName = "Dev.ico" }
  @{Path = "C:\Dev\Github"; IconName = "Github.ico" }
  @{Path = "C:\Dev\Lab"; IconName = "Lab-folder.ico" }
  @{Path = $env:USERPROFILE; IconName = "Profile.ico" }
  @{Path = "$env:USERPROFILE\Autohotkey"; IconName = "AHK.ico" }
  @{Path = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))\Powershell"; IconName = "Powershell.ico" }
  @{Path = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))\WindowsPowershell"; IconName = "Powershell.ico" }
  @{Path = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))\Misc"; IconName = "project.ico" }
  @{Path = "$env:USERPROFILE\Scripts"; IconName = "Util.ico" }
)
  
$folderIconsPath = "$localResourcePath\Icons\Folders"


foreach ($folder in $folders) {
  if (-not (Test-Path $folder.Path)) {
    # The directory does not exist, so create it
    New-Item -Path $folder.Path -ItemType Directory -Force | Out-Null
  }   
  $iconItem = $FolderIconsChildren | Where-Object { $_.Name -eq $folder.IconName }
  $IconPath = Join-Path $folderIconsPath $folder.IconName

  Get-MgDriveItemContent -DriveId $drive.Id -DriveItemId $iconItem.Id -OutFile $IconPath

  $iniPath = Join-Path $folder.Path "desktop.ini"
  if (!(Test-Path $iniPath)) {
    New-Item -Path $iniPath -ItemType File -Force | Out-Null
    # Set folder and ini as System files
    attrib +s $folder.Path
    attrib +s +h $iniPath

    Add-Content -Path $iniPath -Value "[.ShellClassInfo]"
    Add-Content -Path $iniPath -Value "IconResource=$($IconPath),0"
  }
}

# Refresh Quick Access
$shell = New-Object -ComObject shell.application
$QuickAccess = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")

$itemsExceptHome = @($QuickAccess.Items()) | Where-Object { $_.Path -ne $env:USERPROFILE }

# Now remove all Quick Launch items
foreach ($item in $QuickAccess.Items()) {
  $item.InvokeVerb("unpinfromhome")
}

# Add home first
$shell.Namespace($env:USERPROFILE).Self.InvokeVerb("pintohome")

# Re-add in reverse order
foreach ($item in $itemsExceptHome[0..($itemsExceptHome.Length - 1)]) {
  $shell.Namespace($item.Path).Self.InvokeVerb("pintohome")
}

# Set Desktop wallpaper and lockscreen
$everyThingInstallScriptPath = "$env:USERPROFILE\Scripts\set-lockscreen-and-wallpaper.ps1"
$arguments = @("-File", $everyThingInstallScriptPath)
Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait