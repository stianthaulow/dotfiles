Import-Module posh-git
Import-Module Terminal-Icons

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\thaulow.omp.json" | Invoke-Expression

# Fix directory background color - https://github.com/PowerShell/PowerShell/issues/18550
$PSStyle.FileInfo.Directory = "`e[38;2;255;255;255m"

Set-Alias g Set-Bookmark
Set-Alias c code
Set-Alias sqlite sqlite3
Set-Alias n pnpm
Set-Alias c# csharprepl
Set-Alias dot chezmoi
Set-Alias type bat

function dotdir {
  Set-Location -Path "$(chezmoi source-path)\.."
}

function nx {
  pnpm dlx @args
}

function cc {
  $vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
  if (Test-Path $vscodePath) {
    & $vscodePath .
  } else {
    & code .
  }
}

function ds {
  azuredatastudio .
}

function rr {
  npm run dev
}

function newapp {
  npx create-t3-app@latest
}

function dup {
  docker compose up -d
}

function ddn {
  docker compose down
}

function hot {
  code C:\Dev\Autohotkey
}

function rmrf {
  Param(
    [Parameter(Mandatory = $true)]
    [string]$Target
  )
  Remove-Item -Recurse -Force $Target
}
Set-Alias rmr rmrf

function touch($file) { "" | Out-File $file -Encoding UTF8 }

# Open Explorer
function e {
  Invoke-Item .
}

# Edit powershell profile with vscode
function ep() {
  $vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
  $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  if (Test-Path $vscodePath) {
    & $vscodePath $profilePath
  } else {
    & code $profilePath
  }
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

  New-Item -Path $Path -ItemType Directory

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

# Chezmoi completions
. "$env:USERPROFILE\Documents\Powershell\chezmoi-completions.ps1"

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

# winget autocomplete
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

# Fast Node Manager (fnm) autocomplete
fnm env --use-on-cd | Out-String | Invoke-Expression

Import-Module DockerCompletion

# Clear-Host
