$homeChildrenDotFiles = Get-ChildItem -Path $env:USERPROFILE | Where-Object { $_.Name -like ".*" }

foreach ($path in $homeChildrenDotFiles) {
  $path = $path.FullName
  Set-ItemProperty -Path $path -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
}
