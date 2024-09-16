. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Installing Powershell modules..."

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

$modules = @(
  "posh-git"
  "DockerCompletion"
  "PSReadLine"
  "Terminal-Icons"
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

# Install Set-Bookmark
if (-not (Get-Command Set-Bookmark -ErrorAction SilentlyContinue)) {
  Write-Log "Cloning Set-Bookmark"
  $modulesPath = $env:PSModulePath -split ";" | Select-Object -First 1
  $cloneFolder = Join-Path $modulesPath "Set-Bookmark"
  git clone https://github.com/stianthaulow/pwsh-bookmarks $cloneFolder
}


Write-Log "Powershell modules installed."