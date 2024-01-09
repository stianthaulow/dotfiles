Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
Write-Host "Press any key to continue after installing winget"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

Write-Host "Setting up.."