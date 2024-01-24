# Set norwegian keyboard layout
Write-Debug "Setting language and locale..."
$languageList = New-WinUserLanguageList -Language "nb-NO"
$languageList.Add("en-US")
$languageList[0].InputMethodTips.Add("0414:00000414")
$languageList[1].InputMethodTips.Add("0414:00000414")
Set-WinUserLanguageList $languageList -Force
Set-WinSystemLocale "nb-NO"
Set-WinUILanguageOverride -Language "en-US"
Set-Culture "nb-NO"
Write-Debug "Done setting language and locale."

