$toolbarFolderPath = "C:\Tools\Toolbar"
$emptyToolbarFolderPath = "C:\Tools\Empty"
$ShortcutPath = "$toolbarFolderPath\Recycle Bin.lnk"

if (Test-Path $ShortcutPath) {
  exit
}

New-Item -ItemType Directory -Force -Path $toolbarFolderPath
New-Item -ItemType Directory -Force -Path $emptyToolbarFolderPath
$WScriptShell = New-Object -ComObject WScript.Shell
$TargetPath = "shell:RecycleBinFolder"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()

