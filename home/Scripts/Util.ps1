$scriptName = Split-Path $MyInvocation.PSCommandPath -Leaf
$logFolderPath = Join-Path $env:USERPROFILE "Dotlog"
$logPath = Join-Path $logFolderPath "$scriptName.log"
Start-Transcript -Path $logPath
function Write-Log {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )
  
  Write-Debug $Message
  $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

  Write-Host "$date - $Message"
}