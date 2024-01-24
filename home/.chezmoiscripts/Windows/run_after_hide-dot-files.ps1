if ($env:DOT_DEBUG -eq "1") {
  $DebugPreference = "Continue"
}

$homeChildrenDotFiles = Get-ChildItem -Path $env:USERPROFILE | Where-Object { $_.Name -like ".*" }

foreach ($path in $homeChildrenDotFiles) {
  $path = $path.FullName
  Write-Debug "Hiding $path"
  Set-ItemProperty -Path $path -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
}
