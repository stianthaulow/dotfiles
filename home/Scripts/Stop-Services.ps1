$services = @(
  "DiagTrack"  # Diagnostics Tracking Service
  "MapsBroker" # Downloaded Maps Manager
)

foreach ($service in $services) {
  Write-Debug "Trying to disable $service"
  Get-Service -Name $service | Set-Service -StartupType Disabled
}