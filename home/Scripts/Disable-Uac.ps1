. (Join-Path $PSScriptRoot "Util.ps1")

Write-Log "Disabling UAC"
Set-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0