# Create Dev and Tools dir
$directoriesToCreate = @(
  "C:\Dev",
  "C:\Tools"
)
foreach ($directory in $directoriesToCreate) {
  if (-not (Test-Path $directory)) {
    # The directory does not exist, so create it
    New-Item -Path $directory -ItemType Directory | Out-Null
    Write-Host "Created directory: $directory" -ForegroundColor Green
  }   
}