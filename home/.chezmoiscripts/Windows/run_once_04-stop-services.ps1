Write-Host "Disabling services..." -ForegroundColor DarkYellow
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
  Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -File `"$($MyInvocation.MyCommand.Path)`"" -Wait
  exit
}

$services = @(
  "DiagTrack"  # Diagnostics Tracking Service
  "MapsBroker" # Downloaded Maps Manager
)

foreach ($service in $services) {
  Write-Output "Trying to disable $service"
  Get-Service -Name $service | Set-Service -StartupType Disabled
}