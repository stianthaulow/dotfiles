Write-Host "Installing Powershell modules..."

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
  $script = $MyInvocation.MyCommand.Definition
  Start-Process pwsh -ArgumentList "-File `"$script`"" -Verb RunAs -Wait  
  exit
}

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Install-Module DockerCompletion -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser

Write-Host "Powershell modules installed." -ForegroundColor Green