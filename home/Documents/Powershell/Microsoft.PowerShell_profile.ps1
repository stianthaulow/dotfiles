Invoke-Expression (&starship init powershell)

Set-Alias b Set-Bookmark
Set-Alias c code
Set-Alias sqlite sqlite3
Set-Alias n pnpm
Set-Alias c# csharprepl
Set-Alias dot chezmoi
Set-Alias type bat
Set-Alias w winget

function dotdir {
  Set-Location -Path "$(chezmoi source-path)\.."
}

function nx {
  pnpm dlx @args
}

function s {
  if (Test-Path -Path "./package.json") {
    $packageJson = Get-Content -Path "./package.json" -Raw | ConvertFrom-Json
    $packageJson.scripts.PSObject.Properties.Name | ForEach-Object { 
      Write-Host "$($_): " -ForegroundColor Yellow -NoNewline
      Write-Host "$($packageJson.scripts.$_)"
    }
  }
  else {
    Write-Host "No package.json found in the current directory." -ForegroundColor Red
  }
}

function cc {
  code .
}

function ds {
  azuredatastudio .
}

function rr {
  npm run dev
}

function dup {
  docker compose up -d
}

function ddn {
  docker compose down
}

function hot {
  code $env:USERPROFILE\Autohotkey
}

function rmrf {
  Param(
    [Parameter(Mandatory = $true)]
    [string]$Target
  )
  Remove-Item -Recurse -Force $Target
}
Set-Alias rmr rmrf

# New File
function touch($file) { "" | Out-File $file -Encoding UTF8 }

# Open Explorer
function e {
  Invoke-Item .
}

# Edit powershell profile with vscode
function ep() {
  $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  code $profilePath
}

#Edit nvim config
function ev() {
  nvim $env:LOCALAPPDATA\nvim\init.lua
}


# Tab completion like bash
# Set-PSReadlineKeyHandler -Key RightArrow -Function MenuComplete
# Set-PSReadLineKeyHandler -Key Tab -Function ForwardChar

# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
# Powershell won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

# Create dir and cd into it
function mcd {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $Path
  )

  New-Item -Path $Path -ItemType Directory | Out-Null

  Set-Location -Path $Path
}

#Find in files
function fgrep {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $Pattern,
    [Parameter()]
    $FileTypes = "*.*",
    [Parameter()]
    $Path = ".",
    [Parameter()]
    $Recurse = $True
  )
  Get-ChildItem -Path $Path -Include $FileTypes -Recurse $Recurse | Select-String -Pattern $Pattern
}

# Url Decode/Encode
function decode {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $String
  )
  [System.Web.HttpUtility]::UrlDecode($String)
}

function encode {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $String
  )
  [System.Web.HttpUtility]::UrlEncode($String)
}

# CSV
function countc {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $Path,
    $Separator = ","
  )
  (Get-Content -Path $Path -TotalCount 1).Split($Separator).Count
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action {
  # Load modules
  Import-Module posh-git
  $env:POSH_GIT_ENABLED = $true
  Import-Module Terminal-Icons

  Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

  # Winget autocomplete for both "winget" and "w"
  $wingetCompletion = {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }

  # Register for both "winget" and "w"
  Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock $wingetCompletion
  Register-ArgumentCompleter -Native -CommandName w -ScriptBlock $wingetCompletion

  # Dotnet CLI autocompletion
  Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }

  # Load external completions
  . "$env:USERPROFILE\Documents\Powershell\chezmoi-completions.ps1"
  . "$env:USERPROFILE\Documents\Powershell\az-completions.ps1"
  Invoke-Expression -Command $(gh completion -s powershell | Out-String)
  fnm env | Out-String | Invoke-Expression
  Import-Module DockerCompletion

  # Remove event after execution
  Unregister-Event -SourceIdentifier PowerShell.OnIdle -ErrorAction SilentlyContinue
} | Out-Null
