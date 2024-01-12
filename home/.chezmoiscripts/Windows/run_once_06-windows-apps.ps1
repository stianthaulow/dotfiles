$appListPath = "$env:USERPROFILE\apps.json"

if (-not (Test-Path $appListPath)) {
  exit
}

$apps = Get-Content $appListPath | ConvertFrom-Json

$installed = winget list | Out-String
$notInstalled = $apps | Where-Object {
  $installed -notmatch [Regex]::Escape($_.Id)
}

foreach ($app in $notInstalled) {
  $appId = $app.Id
  $appName = $app.Name
  $appArgs = $app.Args
  Write-host "Installing: " $appName
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $appId $appArgs"
  Invoke-Expression "winget $wingetArgs"
}
