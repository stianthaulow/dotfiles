. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Checking if wsl is installed..."
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslFeature -and $wslFeature.State -ne "Enabled") {
  Write-Log "Installing wsl..."
  wsl --install
  Write-Log "Done installing wsl."
}
else {
  Write-Log "wsl already installed."
}