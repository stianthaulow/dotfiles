. (Join-Path $PSScriptRoot "Util.ps1")

# Environment variables set by Chezmoi are not permanent
$isWorkMachine = $env:DOT_IS_WORK -eq "1"

if ($isWorkMachine) {
  Write-Log "Setting environment variables for work machine..."
  [Environment]::SetEnvironmentVariable("DOT_IS_WORK", "1", "User")
}