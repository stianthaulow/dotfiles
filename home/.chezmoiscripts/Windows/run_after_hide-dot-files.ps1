param([switch]$Debug)

if ($Debug -or $env:DOTDEBUG) {
  $DebugPreference = "Continue"
  Start-Transcript -Path "$env:USERPROFILE\hide-dot-files.log" -IncludeInvocationHeader
}
Write-Debug "Running $PSCommandPath"

$homeChildrenDotFiles = Get-ChildItem -Path $env:USERPROFILE | Where-Object { $_.Name -like ".*" }

foreach ($path in $homeChildrenDotFiles) {
  $path = $path.FullName
  Write-Debug "Hiding $path"
  Set-ItemProperty -Path $path -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
}
