$apps = @(
  @{Id = "JanDeDobbeleer.OhMyPosh"; Name = "Oh My Posh" }
  @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" }
  @{Id = "Schniz.fnm"; Name = "Fast Node Manager (fnm)" }
  # @{Id = "Microsoft.PowerToys"; Name = "PowerToys" }
  # @{Id = "Neovim.Neovim"; Name = "Neovim" }
  # @{Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"; Args = "--override '/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders`"'" },
  # @{Id = "AutoHotkey.AutoHotkey"; Name = "AutoHotkey" }
  # @{Id = "Google.Chrome"; Name = "Google Chrome" }
  # @{Id = "7zip.7zip"; Name = "7zip" }
  # @{Id = "Spotify.Spotify"; Name = "Spotify" }
  # @{Id = "Ditto.Ditto"; Name = "Ditto" }
  # @{Id = "GitHub.cli"; Name = "GitHub CLI" }
  # @{Id = "jqlang.jq"; Name = "jq (JSON CLI)" }
  # @{Id = "junegunn.fzf"; Name = "fzf (fuzzy finder)" }
  # @{Id = "Obsidian.Obsidian"; Name = "Obsidian" }
  # @{Id = "Notepad++.Notepad++"; Name = "Notepad++" }
  # @{Id = "Bitwarden.Bitwarden"; Name = "Bitwarden" }
  # @{Id = "Bitwarden.CLI"; Name = "Bitwarden CLI" }
  # @{Id = "DigitalScholar.Zotero"; Name = "Zotero" }
  # @{Id = "voidtools.Everything"; Name = "Everything search" }
  # @{Id = "Discord.Discord"; Name = "Discord" }
  # @{Id = "tailscale.tailscale"; Name = "Tailscale" }
  # @{Id = "NickeManarin.ScreenToGif"; Name = "ScreenToGif" }
  # @{Id = "WireGuard.WireGuard"; Name = "WireGuard" }
  # @{Id = "suse.RancherDesktop"; Name = "Rancher Desktop" }
  # @{Id = "Python.Python.3.10"; Name = "Python 3.10" }
  # @{Id = "Python.Python.3.12"; Name = "Python 3.12" }
  # @{Id = "Microsoft.DotNet.SDK.8"; Name = ".NET 8 SDK" }
  # @{Id = "JGraph.Draw"; Name = "Draw.io (Diagrams.net)" }
  
)

$installed = winget list | Out-String
$notInstalled = $apps | Where-Object {
  $installed -notmatch [Regex]::Escape($_.Id)
}

foreach ($app in $notInstalled) {
  $appId = $app.Id
  $appName = $app.Name
  $appArgs = $app.Args
  Write-host "Installing: " $appName
  $wingetArgs = "install -e -h --accept-source-agreements --accept-package-agreements --id $appId $appArgs"
  Invoke-Expression "winget $wingetArgs"
}
