. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Enabling UAC"
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2