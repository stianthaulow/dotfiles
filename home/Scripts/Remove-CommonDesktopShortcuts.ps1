. (Join-Path $PSScriptRoot "Util.ps1")

$publicDesktopPath = [System.Environment]::GetFolderPath("CommonDesktopDirectory")
$shortcuts = Get-ChildItem -Path $publicDesktopPath -Filter *.lnk
foreach ($shortcut in $shortcuts) {
  Write-Debug "Removing shortcut: $($shortcut.FullName)"
  Remove-Item $shortcut.FullName -Force
}