Write-Debug "Installing Powershell modules..."

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

$modules = @(
  "posh-git"
  "DockerCompletion"
  "PSReadLine"
  "Terminal-Icons"
  "z"
)

foreach ($module in $modules) {
  Write-Debug "Installing $module"
  Install-Module -Name $module -Scope CurrentUser
}

# Install PSFzf if fzf is installed
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  Write-Debug "Installing PSFzf"
  Install-Module -Name PSFzf -Scope CurrentUser
} 


Write-Debug "Powershell modules installed."