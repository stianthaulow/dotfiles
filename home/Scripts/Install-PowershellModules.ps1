. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Installing Powershell modules..."

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

$modules = @(
  "posh-git"
  "DockerCompletion"
  "PSReadLine"
  "Terminal-Icons"
  "z"
)

foreach ($module in $modules) {
  Write-Log "Installing $module"
  Install-Module -Name $module -Scope CurrentUser
}

# Install PSFzf if fzf is installed
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  Write-Log "Installing PSFzf"
  Install-Module -Name PSFzf -Scope CurrentUser
} 


Write-Log "Powershell modules installed."