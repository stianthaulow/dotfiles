if ($env:DOT_DEBUG -eq "1") {
  $DebugPreference = "Continue"
}

Write-Host -ForegroundColor DarkCyan "Ensuring required apps are installed..."

$apps = @(
  @{Id = "Git.Git"; Name = "Git" }
  @{Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
  @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" }
  @{Id = "Schniz.fnm"; Name = "Fast Node Manager (fnm)" }
  @{Id = "Microsoft.PowerShell"; Name = "Powershell Core" }
  @{Id = "sharkdp.bat"; Name = "bat (cat alternative)" }
  @{Id = "junegunn.fzf"; Name = "fzf (fuzzy finder)" }
  @{Id = "ajeetdsouza.zoxide"; Name = "zoxide (smarter cd)" }
)

$installed = winget list | Out-String
$notInstalled = $apps | Where-Object {
  $installed -notmatch [Regex]::Escape($_.Id)
}

if ($notInstalled.Count -ne 0) {
  foreach ($app in $notInstalled) {
    $appId = $app.Id
    $appName = $app.Name
    $appArgs = $app.Args
    Write-Host "Installing: $appName"
    $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $appId $appArgs"
    Invoke-Expression "winget $wingetArgs"
  }
}


