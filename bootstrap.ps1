$githubUserName = "stianthaulow"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb RunAs -ArgumentList $arguments -Wait
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")
  chezmoi init $githubUserName
  Start-Process powershell -Verb RunAs -ArgumentList "chezmoi apply"
  exit
}

Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"

# Disable UAC
[Environment]::SetEnvironmentVariable("BOOTSTRAPPING", "true", [System.EnvironmentVariableTarget]::User)
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

# Pre-prompt chezmoi data
function Read-HostBoolean([String]$Question) {
  $QuestionString = "$($Question)"
  if ($ReadHostBooleanWasInvalid) {
    Write-Host -Object "Please select a valid option" -ForegroundColor Yellow
  }
  switch -Regex (Read-host $QuestionString) {
    '1|Y|Yes|true' { return $true }
    '0|N|No|false' { return $false }
    default { 
      $ReadHostBooleanWasInvalid = $True
      Read-HostBoolean $Question
    }
  }
}
$chezmoiConfigPath = "$env:USERPROFILE\.config\chezmoi\chezmoi.toml"
$email = Read-Host 'What is your email address?'
$isWork = Read-HostBoolean 'Is this a work computer? (y/n)'
$wantWsl = Read-HostBoolean 'Do you want to install WSL? (y/n)'

New-Item -Path $chezmoiConfigPath -ItemType File -Force | Out-Null
Add-Content -Path $chezmoiConfigPath -Value "[data]"
Add-Content -Path $chezmoiConfigPath -Value "email = `"$email`""
Add-Content -Path $chezmoiConfigPath -Value "isWork = $("$isWork".ToLower())"
Add-Content -Path $chezmoiConfigPath -Value "wantWsl = $("$wantWsl".ToLower())"

Write-Host "Press any key to continue after installing winget..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

$apps = @(
  "Microsoft.PowerShell"
  "twpayne.chezmoi"
)

foreach ($app in $apps) {
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $app"
  Invoke-Expression "winget $wingetArgs"
}