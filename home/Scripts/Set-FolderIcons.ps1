. (Join-Path $PSScriptRoot "Util.ps1")

$themePath = "$env:USERPROFILE\Theme"
$isWorkMachine = $env:DOT_WORK -eq "1"

if (-not (Test-Path $themePath)) {
  Write-Log "Theme folder not found"
  exit
}

$myDocumentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)

Write-Log "Setting up folder icons..."
# Folder icons
$folders = @(
  @{Path = "$themePath"; IconName = "theme.ico" }
  @{Path = "$themePath\Icons"; IconName = "icons.ico" }
  @{Path = "$themePath\Wallpaper"; IconName = "wallpaper.ico" }
  @{Path = "$themePath\Fonts"; IconName = "Fonts.ico" }

  @{Path = "C:\Tools"; IconName = "SQL.ico" }
  @{Path = "C:\Dev"; IconName = "Dev.ico"; QuickAccess = $true }
  @{Path = "C:\Dev\Github"; IconName = "Github.ico" }
  @{Path = "C:\Dev\Lab"; IconName = "Lab-folder.ico" }

  @{Path = $env:USERPROFILE; IconName = "Profile.ico" }
  @{Path = "$env:USERPROFILE\Autohotkey"; IconName = "AHK.ico" }
  @{Path = "$env:USERPROFILE\Scripts"; IconName = "Script.ico" }

  @{Path = "$myDocumentsPath\Powershell"; IconName = "Powershell.ico" }
  @{Path = "$myDocumentsPath\WindowsPowershell"; IconName = "WindowsPowershell.ico" }
  @{Path = "$myDocumentsPath\Misc"; IconName = "project.ico" }
)

if ($isWorkMachine) {
  $folders += @{Path = "C:\P"; IconName = "Personal-folder.ico"; QuickAccess = $true }
  $folders += @{Path = "C:\P\Vault"; IconName = "Obsidian.ico"; OnlyIfExist = $true }
}
else {
  $folders += @{Path = "$env:USERPROFILE\Vault"; IconName = "Obsidian.ico"; OnlyIfExist = $true }
  $folders += @{Path = "$env:USERPROFILE\Zotero"; IconName = "Zotero.ico" }
}

$folderIconsPath = "$themePath\Icons\Folders"
foreach ($folder in $folders) {
  if (-not (Test-Path $folder.Path)) {
    if ($folder.OnlyIfExist) {
      Write-Log "Skipping $folder.Path as it does not exist yet"
      continue
    }
    Write-Log "Creating folder $($folder.Path)"
    New-Item -Path $folder.Path -ItemType Directory -Force | Out-Null
  }   
  $IconPath = Join-Path $folderIconsPath $folder.IconName

  $iniPath = Join-Path $folder.Path "desktop.ini"

  Write-Log "Removing $iniPath"
  Remove-Item -Path $iniPath -Force -ErrorAction SilentlyContinue

  if (!(Test-Path $iniPath)) {
    Write-Log "Creating $iniPath"
    New-Item -Path $iniPath -ItemType File -Force | Out-Null
    # Set folder and ini as System files and ini as hidden
    attrib +s $folder.Path
    attrib +s +h $iniPath

    Add-Content -Path $iniPath -Value "[.ShellClassInfo]"
    Add-Content -Path $iniPath -Value "IconResource=$($IconPath),0"
  }
}

# Refresh Quick Access
Write-Log "Refreshing Quick Access"
$shell = New-Object -ComObject shell.application
$QuickAccess = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")

# Pin missing Quick Access folders
foreach ($folder in $folders | Where-Object { $_.QuickAccess }) {
  if (-not ($QuickAccess.Items() | Where-Object { $_.Path -eq $folder.Path })) {
    $shell.Namespace($folder.Path).Self.InvokeVerb("pintohome")
  }
}

# Remove Pictures from Quick Access
Write-Log "Removing Pictures from Quick Access"
$pictures = $QuickAccess.Items() | Where-Object { $_.Name -eq "Pictures" }
if ($pictures) {
  $pictures.InvokeVerb("unpinfromhome")
}

$itemsExceptHome = @($QuickAccess.Items()) | Where-Object { $_.Path -ne $env:USERPROFILE }

# Now remove all Quick Launch items
foreach ($item in $QuickAccess.Items()) {
  Write-Log "Unpinning $($item.Path)"
  $item.InvokeVerb("unpinfromhome")
}

# Add home first
Write-Log "Pining $env:USERPROFILE"
$shell.Namespace($env:USERPROFILE).Self.InvokeVerb("pintohome")

# Re-add in reverse order
foreach ($item in $itemsExceptHome[0..($itemsExceptHome.Length - 1)]) {
  Write-Log "Pinning $($item.Path)"
  $shell.Namespace($item.Path).Self.InvokeVerb("pintohome")
}