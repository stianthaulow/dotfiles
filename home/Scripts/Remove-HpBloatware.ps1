. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Removing HP bloatware..."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -File `"$($MyInvocation.MyCommand.Path)`"" -Wait -WindowStyle Hidden
    exit
}

# Get-Service | Where-Object {$_.DisplayName -match "HP"} | Select-Object -ExpandProperty Name

$services = @(
    "HotKeyServiceUWP",
    "HPAppHelperCap",
    "HPAudioAnalytics",
    "HPDiagsCap",
    "hpLHAgent",
    "hpLHWatchdog",
    "HPNetworkCap",
    "hpsvcsscan",
    "HPSysInfoCap",
    "HpTouchpointAnalyticsService",
    "LanWlanWwanSwitchingServiceUWP"
)

Write-Host "Stop and remove services..." -ForegroundColor Cyan

foreach ($service in $services) {
    Write-Host "Processing $service..." -ForegroundColor Yellow
    try {
        Stop-Service $service -ErrorAction Stop
        Set-Service $service -StartupType Disabled -ErrorAction Stop
        Write-Host "  ✓ Disabled $service" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed: $_" -ForegroundColor Red
    }
}

# winget list | Select-String "HP"

$appsToRemove = @(
    "HP Insights Analytics",
    "HP Insights Analytics - Dependencies",
    "HP Insights"
)

Write-Host "Uninstall apps..." -ForegroundColor Cyan

foreach ($app in $appsToRemove) {
    Write-Host "Attempting to uninstall: $app" -ForegroundColor Yellow
    try {
        $result = winget uninstall $app --silent 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successfully uninstalled: $app" -ForegroundColor Green
        }
        else {
            Write-Host "  ✗ Failed to uninstall: $app (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "    Output: $result" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ✗ Error uninstalling $app : $_" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Uninstall process completed!" -ForegroundColor Cyan