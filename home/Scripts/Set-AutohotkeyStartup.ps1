. (Join-Path $PSScriptRoot "Util.ps1")

$workScriptPath = "$env:USERPROFILE\AutoHotkey\WorkScript.ahk"

if (-not (Test-Path $workScriptPath)) {
  Write-Log "Autohotkey script not set up, skipping..."
  exit
}

$iconPath = "$env:USERPROFILE\AutoHotkey\WorkScript.ico"
$shortCutName = "WorkScript.lnk"
$shortcutPath = Join-Path $env:TEMP $shortCutName
$startupFolderPath = [System.Environment]::GetFolderPath('Startup')

$startUpShortcutPath = Join-Path $startupFolderPath $shortCutName

if (Test-Path $startUpShortcutPath) {
  Write-Log "Autohotkey startup shortcut already set."
  exit
}

$WshShell = New-Object -ComObject WScript.Shell
Write-Log "Creating shortcut in $shortcutPath"
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $workScriptPath
$Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($workScriptPath)
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()

Write-Log "Copying shortcut to $startupFolderPath"
Copy-Item $shortcutPath -Destination $startupFolderPath

Write-Log "Removing temp shortcut from $shortcutPath"
Remove-Item -Path $shortcutPath