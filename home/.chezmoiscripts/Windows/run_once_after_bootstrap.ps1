$ScriptFolderPath = $env:SCRIPTS
$ErrorActionPreference = "Stop"
$Debug = [Environment]::GetEnvironmentVariable("DOT_DEBUG", [System.EnvironmentVariableTarget]::User)

if ($Debug) {
  $DebugPreference = "Continue"
}

$wantWsl = $env:DOT_WANT_WSL -eq "1"

$defaultArgs = @("-NoProfile", "-NoLogo")
function Start-Script {
  param (
    [Parameter()]
    [string]$ScriptName,

    [Parameter()]
    [switch]$AsAdmin,

    [Parameter()]
    [switch]$UseCore,

    [Parameter()]
    [switch]$ShowWindow
  )

  $ScriptPath = Join-Path $ScriptFolderPath "$ScriptName.ps1"

  $arguments = $defaultArgs + @("-Command", "```$ErrorActionPreference='Stop'; & '$ScriptPath'")
  
  if ($Debug) {
    $arguments = $defaultArgs + @("-NoExit") + @("-Command", "```$DebugPreference='Continue'; ```$ErrorActionPreference='Stop'; & '$ScriptPath'")
  }

  $processArgs = "-Wait"

  if (-not $Debug -and -not $ShowWindow) {
    $processArgs += " -WindowStyle Hidden"
  }

  if ($AsAdmin) {
    $processArgs += " -Verb RunAs"
  }

  $interpreter = if ($UseCore) { "pwsh" } else { "powershell" } 

  $expression = "Start-Process $interpreter $processArgs -ArgumentList ""$arguments"""

  $message = "Running $ScriptName"
  if ($AsAdmin) {
    $message += " as Admin"
  }
  $message += "..."

  Write-Host $message -ForegroundColor DarkGray
  Write-Debug "Invoking: $expression"
  Invoke-Expression $expression
  Write-Host "$ScriptName Done." -ForegroundColor Green
}

function Test-PowershellCoreInstalled {
  $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($pwshPath) {
    Write-Debug "Powershell Core is installed"
    return $true
  }
  else {
    Write-Debug "PowerShell Core is not installed."
    return $false
  }
}

# Set language and Keyboard layout
Start-Script "Set-Locale" -AsAdmin

# Install WSL
if ($wantWsl) {
  Start-Script "Install-WSL" -AsAdmin
}

# Set up toolbars
Start-Script "Add-Toolbars"

# Set Windows defaults
Start-Script "Set-WindowsDefaults" -AsAdmin

# Debloat
Start-Script "Remove-Bloat" -AsAdmin

# Stop Services
Start-Script "Stop-Services" -AsAdmin

# Remove taskbar shortcuts
Start-Script "Remove-TaskbarShortcuts"

# Unpin start menu tiles
Start-Script "Remove-StartMenuTiles" -AsAdmin

# Install apps
Start-Script "Install-Apps" -ShowWindow

# Install powershell modules
if (Test-PowershellCoreInstalled) {
  Start-Script "Install-PowershellModules" -UseCore
}

# Set up Autohotkey
Start-Script "Set-AutohotkeyStartup"

# Install node
Start-Script "Install-Node"

# Install fonts
Start-Script "Install-Fonts"

# Set up folders and Icons
Start-Script "Set-FolderIcons"

# Set lockscreen wallpaper
Start-Script "Set-LockscreenWallpaper"

# Set desktop wallpaper
Start-Script "Set-Wallpaper"

# Enable UAC
Start-Script "Enable-Uac" -AsAdmin
