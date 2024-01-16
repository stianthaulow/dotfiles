$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin -or $PSVersionTable.PSEdition -eq "Core") {
  Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -File `"$($MyInvocation.MyCommand.Path)`"" -Wait
  exit
}

$AppXApps = @(
  #Unnecessary Windows 10 AppX Apps
  "*Microsoft.BingNews*"
  "*Microsoft.GetHelp*"
  "*Microsoft.Getstarted*"
  "*Microsoft.Messaging*"
  "*Microsoft.Microsoft3DViewer*"
  "*Microsoft.MicrosoftOfficeHub*"
  "*Microsoft.MicrosoftSolitaireCollection*"
  "*Microsoft.NetworkSpeedTest*"
  "*Microsoft.Office.Sway*"
  "*Microsoft.OneConnect*"
  "*Microsoft.People*"
  "*Microsoft.Print3D*"
  "*Microsoft.SkypeApp*"
  "*Microsoft.WindowsAlarms*"
  "*microsoft.windowscommunicationsapps*"
  "*Microsoft.WindowsFeedbackHub*"
  "*Microsoft.WindowsMaps*"
  "*Microsoft.WindowsSoundRecorder*"
  "*Microsoft.Xbox.TCUI*"
  "*Microsoft.XboxApp*"
  "*Microsoft.XboxGameOverlay*"
  "*Microsoft.XboxIdentityProvider*"
  "*Microsoft.XboxSpeechToTextOverlay*"
  "*Microsoft.ZuneMusic*"
  "*Microsoft.ZuneVideo*"

  #Sponsored Windows 10 AppX Apps
  #Add sponsored/featured apps to remove in the "*AppName*" format
  "*EclipseManager*"
  "*ActiproSoftwareLLC*"
  "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
  "*Duolingo-LearnLanguagesforFree*"
  "*PandoraMediaInc*"
  "*CandyCrush*"
  "*Wunderlist*"
  "*Flipboard*"
  "*Twitter*"
  "*Facebook*"
)

Write-Host "Removing AppX packages..." -ForegroundColor DarkYellow
foreach ($App in $AppXApps) {
  Write-Host "Checking $App"
  # Check for the package for the current user
  $userPackage = Get-AppxPackage -Name $App -ErrorAction SilentlyContinue
  if ($userPackage) {
    Write-Host "Removing Package $App for Current User" -ForegroundColor DarkYellow
    Remove-AppxPackage -Package $userPackage.PackageFullName -ErrorAction SilentlyContinue
  }

  # Check for the package for all users
  $allUsersPackage = Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue
  if ($allUsersPackage) {
    Write-Host "Removing Package $App for All Users" -ForegroundColor DarkYellow
    Remove-AppxPackage -Package $allUsersPackage.PackageFullName -AllUsers -ErrorAction SilentlyContinue
  }

  # Check for provisioned packages
  $provisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App
  if ($provisionedPackage) {
    Write-Host "Removing Provisioned Package $App" -ForegroundColor DarkYellow
    Remove-AppxProvisionedPackage -PackageName $provisionedPackage.PackageName -Online -ErrorAction SilentlyContinue
  }
}
