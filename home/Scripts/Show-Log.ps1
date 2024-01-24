Start-Transcript -Path "$env:USERPROFILE\dot_transcript.log" -Append
$logPath = "$env:USERPROFILE\dot.log"
if (-not (Test-Path $logPath)) {
  New-Item -Path $logPath -ItemType File | Out-Null
}
Get-Content -Path $logPath -Wait