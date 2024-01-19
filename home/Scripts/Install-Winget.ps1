
Write-Host 'Checking for updated winget...'
$debug = [System.Environment]::GetEnvironmentVariable('DOTDEBUG', 'User')
if ($debug) { $DebugPreference = 'Continue' }

$wingetApiUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
$response = Invoke-RestMethod -Uri $wingetApiUrl

function Get-Version($versionString) {
  $versionString = $versionString.TrimStart('v').TrimEnd('-preview')
  return [System.Version]::new($versionString)
}

$latestVersion = Get-Version($response.tag_name)

try {
  $currentWingetVersionString = winget --version
  $currentWingetVersion = Get-Version($currentWingetVersionString)
}
catch {
  $currentWingetVersion = $false
  write-debug 'Winget not installed'
}

if (-not $currentWingetVersion -or $currentWingetVersion -lt $latestVersion) {
  Write-Host 'Downloading latest winget...'
  $wingetPackageName = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
  $packageUrl = $response.assets | Where-Object { $_.Name -eq $wingetPackageName } | Select-Object -ExpandProperty browser_download_url
  $xamlUiUrl = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx'
  $vclibsUrl = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

  $tempFolderPath = Join-Path -Path $env:Temp -ChildPath 'Winget'
  New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
  $packagePath = Join-Path -Path $tempFolderPath -ChildPath $(Split-Path -Leaf $packageUrl)
  $xamlUiPath = Join-Path -Path $tempFolderPath -ChildPath $(Split-Path -Leaf $xamlUiUrl)
  $vclibsPath = Join-Path -Path $tempFolderPath -ChildPath $(Split-Path -Leaf $vclibsUrl)
  $ProgressPreference = 'SilentlyContinue'  
  Invoke-WebRequest -Uri $packageUrl -OutFile $packagePath
  Invoke-WebRequest -Uri $xamlUiUrl -OutFile $xamlUiPath
  Invoke-WebRequest -Uri $vclibsUrl -OutFile $vclibsPath
  $ProgressPreference = 'Continue'
  Add-AppxPackage -ForceApplicationShutdown -Path $vclibsPath
  Add-AppxPackage -ForceApplicationShutdown -Path $xamlUiPath
  Add-AppxPackage -ForceApplicationShutdown -Path $packagePath
  Remove-item $tempFolderPath -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host 'Winget installed' -ForegroundColor Green
}