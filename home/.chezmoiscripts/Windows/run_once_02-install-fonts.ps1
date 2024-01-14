$jetBrainsFonts = Get-ChildItem -Path "$env:windir\Fonts" -Filter "*JetBrainsMonoNerdFont*.ttf"

if ($jetBrainsFonts.Count -gt 0) {
  exit
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait
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
  
    Write-Host "Installing font: $fontFile with font name '$fontName'"
  
    If (!(Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name))) {  
      Write-Host "Copying font: $fontFile"
      Copy-Item -Path $fontFile.FullName -Destination ("$($env:windir)\Fonts\" + $fontFile.Name) -Force 
    }
    else { Write-Host "Font already exists: $fontFile" }
  
    If (!(Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
      Write-Host "Registering font: $fontFile"
      New-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
    }
    else { Write-Host "Font already registered: $fontFile" }
  }
  catch {            
    Write-Host "Error installing font: $fontFile. " $_.exception.message
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
  
    Write-Host "Uninstalling font: $fontFile with font name '$fontName'"
  
    If (Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name)) {  
      Write-Host "Removing font: $fontFile"
      Remove-Item -Path "$($env:windir)\Fonts\$($fontFile.Name)" -Force 
    }
    else { Write-Host "Font does not exist: $fontFile" }
  
    If (Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue) {  
      Write-Host "Unregistering font: $fontFile"
      Remove-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force                      
    }
    else { Write-Host "Font not registered: $fontFile" }
  }
  catch {            
    Write-Host "Error uninstalling font: $fontFile. " $_.exception.message
  }        
}


# JetBrains Mono Nerdfont
$url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"

$tempPath = [System.IO.Path]::GetTempPath()
$downloadPath = Join-Path $tempPath ([System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $downloadPath | Out-Null
$zipPath = Join-Path $downloadPath "JetBrainsMono.zip"
Write-Host "Downloading $url to $zipPath"
$progressPreference = 'silentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $zipPath
$progressPreference = 'Continue'
Expand-Archive -LiteralPath $zipPath -DestinationPath $downloadPath

Write-Host "Installing Fonts"
foreach ($FontItem in (Get-ChildItem -Path $downloadPath | 
    Where-Object { ($_.Name -like '*.ttf') -or ($_.Name -like '*.otf') })) {  
  Install-Font -fontFile $FontItem.FullName  
}