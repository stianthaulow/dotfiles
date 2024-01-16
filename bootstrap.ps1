param([switch]$Debug)

if ($Debug -or $env:DOTDEBUG) {
  $DebugPreference = "Continue"
  Start-Transcript -Path "$env:USERPROFILE\bootstrap.log" -IncludeInvocationHeader -Append
}
Write-Debug "Running $PSCommandPath"

$githubUserName = "stianthaulow"

$ErrorActionPreference = 'Stop'

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if (!$isAdmin) {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Write-Debug "Restarting as admin"
  if ($debug) {
    $arguments += " -NoExit"
    Stop-Transcript
  }
  Start-Process powershell -Verb RunAs -ArgumentList $arguments -Wait
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
  Write-Debug "Installing chezmoi"
  chezmoi init $githubUserName
  Write-Debug "Applying chezmoi as admin"
  Write-Host "Press any key to continue and apply dotfiles..."
  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  Start-Process powershell -Verb RunAs -ArgumentList "chezmoi apply" -Wait
  Write-Debug "Done"
  exit
}

Write-Debug "Disabling UAC"
[Environment]::SetEnvironmentVariable("BOOTSTRAPPING", "true", [System.EnvironmentVariableTarget]::User)
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

Write-Debug "Disabling Edge first run"
New-Item -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1

Write-Debug "Pre-prompt chezmoi data"
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

$apps = @(
  @{Id = "Git.Git"; Name = "Git" }
  @{Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
  @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" }
  @{Id = "Schniz.fnm"; Name = "Fast Node Manager (fnm)" }
  @{Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"; Args = "--override '/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders`"'" },
  @{Id = "Microsoft.PowerToys"; Name = "PowerToys"; Args = "--override '/SILENT'" }
  @{Id = "Microsoft.PowerShell"; Name = "Powershell Core" }
  @{Id = "Bitwarden.CLI"; Name = "Bitwarden CLI" }
  @{Id = "Bitwarden.Bitwarden"; Name = "Bitwarden" }
  @{Id = "AutoHotkey.AutoHotkey"; Name = "AutoHotkey" }
  @{Id = "voidtools.Everything"; Name = "Everything search" }
  @{Id = "Ditto.Ditto"; Name = "Ditto" }
  @{Id = "Neovim.Neovim"; Name = "Neovim" }
  @{Id = "Google.Chrome"; Name = "Google Chrome" }
  @{Id = "7zip.7zip"; Name = "7zip" }
  @{Id = "Spotify.Spotify"; Name = "Spotify" }
  @{Id = "GitHub.cli"; Name = "GitHub CLI" }
  @{Id = "jqlang.jq"; Name = "jq (JSON CLI)" }
  @{Id = "junegunn.fzf"; Name = "fzf (fuzzy finder)" }
  @{Id = "Obsidian.Obsidian"; Name = "Obsidian" }
  @{Id = "Notepad++.Notepad++"; Name = "Notepad++" }
  @{Id = "DigitalScholar.Zotero"; Name = "Zotero" }
  @{Id = "Discord.Discord"; Name = "Discord" }
  @{Id = "tailscale.tailscale"; Name = "Tailscale" }
  @{Id = "NickeManarin.ScreenToGif"; Name = "ScreenToGif" }
  @{Id = "WireGuard.WireGuard"; Name = "WireGuard" }
  @{Id = "suse.RancherDesktop"; Name = "Rancher Desktop" }
  @{Id = "Python.Python.3.10"; Name = "Python 3.10" }
  @{Id = "Python.Python.3.12"; Name = "Python 3.12" }
  @{Id = "Microsoft.DotNet.SDK.8"; Name = ".NET 8 SDK" }
  @{Id = "JGraph.Draw"; Name = "Draw.io (Diagrams.net)" }
)


function Show-Apps($apps, $currentSelection, $selectedApps) {
  for ($i = 0; $i -lt $apps.Count; $i++) {
    if ($i -eq $currentSelection) {
      Write-Host "-> $($apps[$i].Name)" -ForegroundColor Cyan
    }
    elseif ($selectedApps -contains $i) {
      Write-Host "[x] $($apps[$i].Name)"
    }
    else {
      Write-Host "[ ] $($apps[$i].Name)"
    }
  }
}

$currentIndex = 0
$selectedApps = 0..($apps.Count - 1)

do {
  Clear-Host
  Write-Host "Select Applications to Install" -ForegroundColor Green
  Write-Host "Press [Space] to toggle selection, [A] to select all, [Enter] to continue" -ForegroundColor DarkGray
  Show-Apps $apps $currentIndex $selectedApps

  $key = [System.Console]::ReadKey($true)

  switch ($key.Key) {
    'UpArrow' {
      if ($currentIndex -gt 0) { $currentIndex-- }
    }
    'DownArrow' {
      if ($currentIndex -lt $apps.Count - 1) { $currentIndex++ }
    }
    'Spacebar' {
      if ($selectedApps -contains $currentIndex) {
        $selectedApps = $selectedApps | Where-Object { $_ -ne $currentIndex }
      }
      else {
        $selectedApps += $currentIndex
      }
    }
    'A' {
      if ($selectedApps -contains $currentIndex) {
        $selectedApps = @()
      }
      else {
        $selectedApps = 0..($apps.Count - 1)
      }
    }
    'Enter' {
      break
    }
  }
} while ($key.Key -ne 'Enter')

if ($selectedApps.Count -ne 0) {
  $appListPath = "$env:USERPROFILE\apps.json"
  $apps | Where-Object { $selectedApps -contains $apps.IndexOf($_) } | ConvertTo-Json | Out-File $appListPath
}


$wingetApiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$response = Invoke-RestMethod -Uri $wingetApiUrl

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
  Write-Host "Downloading latest winget..."
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

Write-Host "Press any key to continue after installing winget..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

function Install-App($app) {
  Write-Debug "Installing $app"
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $app"
  Invoke-Expression "winget $wingetArgs"
}

Install-App "Microsoft.PowerShell"

Install-App "Git.Git"
$refreshEnvCommand = '$env:Path = [System.Environment]::GetEnvironmentVariable(''Path'', ''Machine'')'
$gitHubArgs = @("-Command", "$refreshEnvCommand; git credential-manager github login")
Write-Debug "Logging in to GitHub"
Start-Process pwsh -ArgumentList $gitHubArgs

Install-App "twpayne.chezmoi"
