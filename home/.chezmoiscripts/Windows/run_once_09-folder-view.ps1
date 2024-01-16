# if ([Environment]::GetEnvironmentVariable("BOOTSTRAPPING", [System.EnvironmentVariableTarget]::User)) {
#   $shell = New-Object -ComObject shell.application

#   $paths = @(
#     $env:USERPROFILE
#     [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
#     "C:\Dev"
#     "$env:USERPROFILE\Resources"
#   )

#   explorer
#   $windows = $shell.Windows()

#   $count = 1
#   while (-not $window -or $count -eq 5) {
#     Start-Sleep -Seconds 1
#     $window = $windows | Where-Object { $_.LocationName -eq "Quick access" }
#     $count += 1
#   }

#   $window.Document.CurrentViewMode = 1
#   $window.Document.IconSize = 96

#   foreach ($path in $paths) {
#     $window.Navigate($path)
#     Start-Sleep -Seconds 1
#     $window.Document.CurrentViewMode = 1
#     $window.Document.IconSize = 96
#   }
# }