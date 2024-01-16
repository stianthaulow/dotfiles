function Get-Version($versionString) {
  $versionString = $versionString.TrimStart("v").TrimEnd("-preview")
  return [System.Version]::new($versionString)
}

$latestVersion = Get-Version($response.tag_name)

try {
  $currentWingetVersionString = winget --version
  $currentWingetVersion = Get-Version($currentWingetVersionString)
}
catch {
  $currentWingetVersion = $false
}

if (-not $currentWingetVersion -or $currentWingetVersion -lt $latestVersion) {
  Write-Host "Downloading lastet winget..."
  $wingetPackageName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
  $packageUrl = $response.assets | Where-Object { $_.Name -eq $wingetPackageName } | Select-Object -ExpandProperty browser_download_url

  $tempFolderPath = Join-Path -Path $env:Temp -ChildPath "Winget"
  New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
  $packagePath = Join-Path -Path $tempFolderPath -ChildPath $(Split-Path -Leaf $packageUrl)
  $ProgressPreference = 'SilentlyContinue'  
  Invoke-WebRequest -Uri $packageUrl -OutFile $packagePath
  $ProgressPreference = 'Continue'
  Write-Host "Installing winget..."
  Add-AppxPackage -Path $packagePath
  Remove-item $tempFolderPath -Recurse -Force -ErrorAction SilentlyContinue
}