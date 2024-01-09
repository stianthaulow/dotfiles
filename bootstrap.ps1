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
Write-Host "Press any key to continue after installing winget..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

$apps = @(
  "Git.Git"
  "Microsoft.PowerShell"
  "twpayne.chezmoi"
)

foreach ($app in $apps) {
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $app"
  Invoke-Expression "winget $wingetArgs"
}