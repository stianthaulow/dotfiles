$githubUserName = "stianthaulow"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$logpath = "$env:USERPROFILE\bootstrap.log"
New-Item -Path $logpath -ItemType File -Force | Out-Null
function log($message) {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -Path $logpath -Value "$message - $timestamp"
}

if (!$isAdmin) {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  log("Restarting as admin")
  Start-Process powershell -Verb RunAs -ArgumentList $arguments -Wait
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")
  log("Logging in to GitHub")
  git credential-manager github login
  log("Installing chezmoi")
  chezmoi init $githubUserName
  log("Applying chezmoi as admin")
  Start-Process powershell -Verb RunAs -ArgumentList "chezmoi apply"
  exit
}

Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"


log("Disabling UAC")
[Environment]::SetEnvironmentVariable("BOOTSTRAPPING", "true", [System.EnvironmentVariableTarget]::User)
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

log("Pre-prompt chezmoi data")
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
  @{Id = "Microsoft.PowerToys"; Name = "PowerToys" }
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
  $selectedApps | ConvertTo-Json | Out-File $appListPath
}


Write-Host "Press any key to continue after installing winget..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

$apps = @(
  "Git.Git"
  "Microsoft.PowerShell"
  "twpayne.chezmoi"
)

foreach ($app in $apps) {
  log("Installing $app")
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $app"
  Invoke-Expression "winget $wingetArgs"
}