Write-Debug "Creating taskbar toolbar folders..."
$toolbarFolderPath = "C:\Tools\Toolbar"
$emptyToolbarFolderPath = "C:\Tools\Empty"
$ShortcutPath = "$toolbarFolderPath\Recycle Bin.lnk"

if (Test-Path $ShortcutPath) {
  Write-Debug "Recycle Bin shortcut already exists, skipping toolbar folder creation."  
  exit
}

New-Item -ItemType Directory -Force -Path $toolbarFolderPath | Out-Null
New-Item -ItemType Directory -Force -Path $emptyToolbarFolderPath | Out-Null
$WScriptShell = New-Object -ComObject WScript.Shell
$TargetPath = "shell:RecycleBinFolder"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()
Write-Debug "Done creating taskbar toolbar folders..."