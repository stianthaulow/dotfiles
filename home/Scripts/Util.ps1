function Write-Log {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )
  
  Write-Debug $Message

  $logPath = "$env:USERPROFILE\dot.log"
  if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType File | Out-Null
  }

  $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $callerScriptName = Split-Path $MyInvocation.PSCommandPath -Leaf

  $logMessage = "$date - $callerScriptName - $Message"
  Add-Content -Path $logPath -Value $logMessage
}