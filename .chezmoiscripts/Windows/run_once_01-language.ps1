Write-Host "Setting language and keyboard layout..."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin -or $PSVersionTable.PSEdition -eq "Core") {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait -WindowStyle Hidden
  exit
}

# Set norwegian keyboard layout
$languageList = New-WinUserLanguageList -Language "nb-NO"
$languageList.Add("en-US")
$languageList[0].InputMethodTips.Add("0414:00000414")
Set-WinUserLanguageList $languageList -Force
Set-Culture "nb-NO"
Set-WinSystemLocale "nb-NO"
Set-WinUILanguageOverride -Language "en-US"