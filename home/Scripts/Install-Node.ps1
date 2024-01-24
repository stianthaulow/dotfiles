. (Join-Path $PSScriptRoot "Util.ps1")

if (Get-Command fnm -ErrorAction SilentlyContinue) {
  Write-Log "Installing node LTS"
  fnm install --lts
}
else {
  Write-Log "Fast Node Manager (fnm) is not installed, skipping..."
}