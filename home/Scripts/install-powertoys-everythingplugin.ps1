Write-Host "Installing: Everything search plugin for PowerToys..."
$runPluginsPath = "$env:LOCALAPPDATA\PowerToys\RunPlugins\"
$everythingPluginPath = Join-Path -Path $runPluginsPath -ChildPath "Everything"
if (Test-Path -Path $everythingPluginPath) {
  $pluginManifestPath = Join-Path -Path $everythingPluginPath -ChildPath "plugin.json"
  $pluginManifest = Get-Content -Path $pluginManifestPath -Raw | ConvertFrom-Json
  $installedVersion = $pluginManifest.Version
  Write-Debug "Installed version: $installedVersion"
}

$repoOwner = 'lin-ycv'
$repoName = 'EverythingPowerToys'
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
$response = Invoke-RestMethod -Uri $apiUrl

Write-Debug "Response: $response"

$latestTag = ($response.tag_name).TrimStart("v")

if ($latestTag -eq $installedVersion) {
  Write-Host "Everything search plugin for PowerToys is already up to date." -ForegroundColor Green
  exit
}

if ($response.assets.Count -gt 0) {
  Write-Debug "Response assets: $($response.assets)"
  $downloadUrl = $response.assets[0].browser_download_url
  $tempFolderPath = Join-Path -Path $env:Temp -ChildPath "Everything"
  Remove-item $tempFolderPath -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
  $tempArchivePath = Join-Path -Path $tempFolderPath -ChildPath $(Split-Path -Leaf $downloadUrl)
  Invoke-WebRequest -Uri $downloadUrl -OutFile $tempArchivePath
  Expand-Archive -LiteralPath $tempArchivePath -DestinationPath $tempFolderPath

  Remove-Item $everythingPluginPath -Recurse -Force -ErrorAction SilentlyContinue
  $extractedPluginPath = Join-Path -Path $tempFolderPath -ChildPath "Everything"
  Move-Item -Path $extractedPluginPath -Destination $runPluginsPath -Force
  Write-Host "Installed version $latestTag" -ForegroundColor Green
}
else {
  Write-Host "Could not find asset file for latest release of Everything search plugin for PowerToys." -ForegroundColor Red
}


