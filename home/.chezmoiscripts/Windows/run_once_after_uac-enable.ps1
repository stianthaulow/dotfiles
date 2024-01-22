param([switch]$Debug)

if ($Debug -or $env:DOTDEBUG) {
  $DebugPreference = "Continue"
  Start-Transcript -Path "$env:USERPROFILE\enable-uac.log" -IncludeInvocationHeader
}
Write-Debug "Running $PSCommandPath"
Write-Host "Enabling UAC..."
pause

if ([Environment]::GetEnvironmentVariable("BOOTSTRAPPING", [System.EnvironmentVariableTarget]::User)) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  
  if (!$isAdmin -or $PSVersionTable.PSEdition -eq "Core") {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait
    exit
  }
  [Environment]::SetEnvironmentVariable("BOOTSTRAPPING", $null, [System.EnvironmentVariableTarget]::User)
  Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
  
  Remove-Item "$env:USERPROFILE\apps.json"
}

