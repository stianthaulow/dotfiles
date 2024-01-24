if (Get-Command fnm -ErrorAction SilentlyContinue) {
  Write-Debug "Installing node LTS"
  fnm install --lts
} else {
  Write-Debug "Fast Node Manager (fnm) is not installed, skipping..."
}