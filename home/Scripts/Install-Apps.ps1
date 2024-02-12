. (Join-Path $PSScriptRoot "Util.ps1")

. (Join-Path $PSScriptRoot "Move-Win.ps1")

Move-CurrentWindowRight

$appListPath = "$env:USERPROFILE\apps.json"

$Host.UI.RawUI.WindowTitle = "Installing Apps"

if (-not (Test-Path $appListPath)) {
  Write-Log "$appListPath not found, skipping."
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
  Write-Log "Installing: $appName"
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $appId $appArgs"
  Invoke-Expression "winget $wingetArgs"
}

Remove-Item $appListPath 