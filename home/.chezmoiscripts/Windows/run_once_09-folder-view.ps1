$shell = New-Object -ComObject shell.application

$paths = @(
  $env:USERPROFILE
  "$([environment]::getfolderpath("mydocuments"))"
)

Invoke-Item "C:\Dev"
$windows = $shell.Windows()
$window = $windows | Where-Object { $_.LocationName -eq "Dev" }

$count = 1
while (-not $window -or $count -eq 5) {
  Start-Sleep -Seconds 1
  $window = $windows | Where-Object { $_.LocationName -eq "Dev" }
  $count += 1
}

$window.Document.CurrentViewMode = 1
$window.Document.IconSize = 96

foreach ($path in $paths) {
  $window.Navigate($path)
  Start-Sleep -Seconds 1
  $window.Document.CurrentViewMode = 1
  $window.Document.IconSize = 96
}

$window.Navigate($env:USERPROFILE)
$window.Document.CurrentViewMode = 1
$window.Document.IconSize = 96

