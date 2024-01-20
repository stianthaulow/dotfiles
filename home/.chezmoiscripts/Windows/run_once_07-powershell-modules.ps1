Write-Host "Installing Powershell modules..."

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

$modules = @(
  "posh-git"
  "DockerCompletion"
  "PSReadLine"
  "Terminal-Icons"
  "z"
)

foreach ($module in $modules) {
  Write-Host "Installing $module"
  Install-Module -Name $module -Scope CurrentUser
}

# Install PSFzf if fzf is installed
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  Write-Host "Installing PSFzf"
  Install-Module -Name PSFzf -Scope CurrentUser
} 


Write-Host "Powershell modules installed." -ForegroundColor Green