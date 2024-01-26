param([switch]$Debug)

$Host.UI.RawUI.WindowTitle = "Bootstrapping"

$logFolderPath = Join-Path $env:USERPROFILE "Dotlog"
$logPath = Join-Path $logFolderPath "bootstrap.log"
Start-Transcript -Path $logPath

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isRunningInWindowsSandbox = $env:username -eq "WDAGUtilityAccount"

if ($isAdmin -and -not $isRunningInWindowsSandbox) {
  Write-Host "Start boostrap in a non admin shell" -ForegroundColor Red
  exit
}

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

if ($Debug -or $env:DOT_DEBUG -eq "1") {
  $DebugPreference = "Continue"
  [System.Environment]::SetEnvironmentVariable("DOT_DEBUG", "1", "User")
  
}

function Write-Log {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )
  
  Write-Debug $Message

  $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "$date - $Message"
}

$githubUserName = "stianthaulow"
$ErrorActionPreference = 'Stop'

function Set-BoostrapDefaults() {
  Write-Log "Disabling UAC and Edge first run"
  $defaultsScriptBlock = {
    Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
    New-Item -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" -Force | Out-Null
    New-Item -Path "REGISTRY::HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge" -Force | Out-Null
    Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1
    Set-ItemProperty -Path "REGISTRY::CURRENT_USER\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1
  }
  Start-Process powershell -Verb RunAs -Wait -WindowStyle Hidden -ArgumentList "-NoProfile -Command `"$defaultsScriptBlock`"" 
}


function Install-Winget() {
  $wingetScriptBlock = {
    $Host.UI.RawUI.WindowTitle = 'Installing or updating winget'
    Write-Host 'Checking for updated winget...'
    $debug = [System.Environment]::GetEnvironmentVariable('DOT_DEBUG', 'User') -eq '1'
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
  }
  Start-Process powershell -ArgumentList "-NoProfile -Command `"$wingetScriptBlock`""
}

function Initialize-Chezmoi() {
  Write-Log "Installing chezmoi"
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
  chezmoi init $githubUserName

  Write-Log "Applying chezmoi as admin"
  Start-Process powershell -Verb RunAs -ArgumentList "chezmoi apply" -Wait
  Write-Log "Done 🎉"
}

Set-BoostrapDefaults

Install-Winget

Write-Log "Pre-prompt chezmoi data"
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
$email = if ($env:DOT_EMAIL) { $env:DOT_EMAIL } else { Read-Host 'What is your email address?' }
$isWork = if ($env:DOT_IS_WORK) { $env:DOT_IS_WORK } else { Read-HostBoolean 'Is this a work computer? (y/n)' }
$wantWsl = if ($env:DOT_WANT_WSL) { $env:DOT_WANT_WSL } else { Read-HostBoolean 'Do you want to install WSL? (y/n)' }

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
  @{Id = "lin-ycv.EverythingPowerToys"; Name = "Everything Powertoys plugin" }
  @{Id = "Ditto.Ditto"; Name = "Ditto" }
  @{Id = "Neovim.Neovim"; Name = "Neovim" }
  @{Id = "Google.Chrome"; Name = "Google Chrome" }
  @{Id = "7zip.7zip"; Name = "7zip" }
  @{Id = "Spotify.Spotify"; Name = "Spotify" }
  @{Id = "sharkdp.bat"; Name = "bat (cat alternative)" }
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

if (-not $isRunningInWindowsSandbox) {
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

  # Open browser to authenticate with GitHub
  Start-Process "https://github.com/login?login=$githubUserName"

}

function Wait-ForWinget {
  param(
    [int]$IntervalSeconds = 1,
    [int]$TimeoutSeconds = 180 # 3 mins
  )

  $startTime = Get-Date
  $timeout = $startTime.AddSeconds($TimeoutSeconds)

  while ((Get-Date) -lt $timeout) {
    try {
      Get-Command winget -ErrorAction Stop | Out-Null
      return
    }
    catch {
      Write-Debug "winget not installed yet. Waiting for $IntervalSeconds seconds."
      Start-Sleep -Seconds $IntervalSeconds
    }
  }

  Write-Host "Press any key to continue after installing winget..."
  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

Wait-ForWinget

# Refresh path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

function Install-App($app) {
  Write-Log "Installing $app"
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $app"
  Invoke-Expression "winget $wingetArgs"
}

$installGit = {
  $Host.UI.RawUI.WindowTitle = 'Installing Git'
  winget install -e -h --accept-source-agreements --accept-package-agreements --id Git.Git
}
Start-Process powershell -Verb RunAs -ArgumentList "-Command $installGit" -Wait

# Refresh path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($env:DOT_GITHUB_PAT) {
  $credential = @(
    "protocol=https"
    "host=github.com"
    "username=$githubUserName"
    "password=$env:DOT_GITHUB_PAT"
  )
  $credential -join "`n" | git credential-manager store
}
else {
  git credential-manager github login --browser --username $githubUserName
}

Install-App "Microsoft.PowerShell"
Install-App "twpayne.chezmoi"

Initialize-Chezmoi