$workScriptPath = "$env:USERPROFILE\AutoHotkey\WorkScript.ahk"
$iconPath = "$env:USERPROFILE\AutoHotkey\WorkScript.ico"
$shortcutPath = "$env:TEMP\WorkScript.lnk"
$startupFolderPath = [System.Environment]::GetFolderPath('Startup')

$WshShell = New-Object -ComObject WScript.Shell

$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $workScriptPath
$Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($scriptPath)
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()

Copy-Item $shortcutPath -Destination $startupFolderPath

Remove-Item -Path $shortcutPath