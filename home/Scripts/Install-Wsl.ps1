Write-Debug "Checking if wsl is installed..."
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslFeature -and $wslFeature.State -ne "Enabled") {
  Write-Debug "Installing wsl..."
  wsl --install
  Write-Debug "Done installing wsl."
} else {
    Write-Debug "wsl already installed."
}