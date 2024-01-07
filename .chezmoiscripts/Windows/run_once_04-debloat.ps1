function Test-IsAdmin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
  # Relaunch the script with administrator rights
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait
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
  "*Spotify*"
)

foreach ($App in $AppXApps) {
  Write-Host "Removing Package $App" -ForegroundColor DarkYellow
  Get-AppxPackage -Name $App | Remove-AppxPackage -ErrorAction SilentlyContinue
  Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
  Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

