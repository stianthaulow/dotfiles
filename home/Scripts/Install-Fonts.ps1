$fontsPath = "$env:USERPROFILE\Theme\Fonts"

if (-not (Test-Path $fontsPath)) {
  Write-Debug "Theme Fonts folder not found"
  exit
}

$jetBrainsFonts = Get-ChildItem -Path "$env:windir\Fonts" -Filter "*JetBrainsMonoNerdFont*.ttf"

if ($jetBrainsFonts.Count -gt 0) {
  Write-Debug "JetBrains Mono NerdFont already installed."
  exit
}

Add-Type -AssemblyName PresentationCore
function Install-Font {  
  param  
  (  
    [System.IO.FileInfo]$fontFile  
  )  
        
  try { 
    #get font name
    $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
    $family = $gt.Win32FamilyNames['en-us']
    if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
    $face = $gt.Win32FaceNames['en-us']
    if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
    $fontName = ("$family $face").Trim() 

    switch ($fontFile.Extension) {  
      ".ttf" { $fontName = "$fontName (TrueType)" }  
      ".otf" { $fontName = "$fontName (OpenType)" }  
    }  
  
    Write-Debug "Installing font: $fontFile with font name '$fontName'"
  
    If (!(Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name))) {  
      Write-Debug "Copying font: $fontFile"
      Copy-Item -Path $fontFile.FullName -Destination ("$($env:windir)\Fonts\" + $fontFile.Name) -Force 
    }
    else { Write-Debug "Font already exists: $fontFile" }
  
    If (!(Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
      Write-Debug "Registering font: $fontFile"
      New-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
    }
    else { Write-Debug "Font already registered: $fontFile" }
  }
  catch {            
    Write-Debug "Error installing font: $fontFile. " $_.exception.message
  }
    
} 
  
function Uninstall-Font {  
  param  
  (  
    [System.IO.FileInfo]$fontFile  
  )  
        
  try { 
  
    #get font name
    $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
    $family = $gt.Win32FamilyNames['en-us']
    if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
    $face = $gt.Win32FaceNames['en-us']
    if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
    $fontName = ("$family $face").Trim()
    switch ($fontFile.Extension) {  
      ".ttf" { $fontName = "$fontName (TrueType)" }  
      ".otf" { $fontName = "$fontName (OpenType)" }  
    }  
  
    Write-Debug "Uninstalling font: $fontFile with font name '$fontName'"
  
    If (Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name)) {  
      Write-Debug "Removing font: $fontFile"
      Remove-Item -Path "$($env:windir)\Fonts\$($fontFile.Name)" -Force 
    }
    else { Write-Debug "Font does not exist: $fontFile" }
  
    If (Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue) {  
      Write-Debug "Unregistering font: $fontFile"
      Remove-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force                      
    }
    else { Write-Debug "Font not registered: $fontFile" }
  }
  catch {            
    Write-Debug "Error uninstalling font: $fontFile. " $_.exception.message
  }        
}

Write-Debug "Installing Fonts"
foreach ($FontItem in (Get-ChildItem -Path $fontsPath | 
    Where-Object { ($_.Name -like '*.ttf') -or ($_.Name -like '*.otf') })) {  
  Install-Font -fontFile $FontItem.FullName  
}