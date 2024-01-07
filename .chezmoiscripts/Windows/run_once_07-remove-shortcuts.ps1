function Test-IsAdmin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
  # Relaunch the script with administrator rights
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments -Wait
  exit
}

# Remove all desktop shortcuts
$userDesktopPath = [System.Environment]::GetFolderPath("Desktop")
$publicDesktopPath = [System.Environment]::GetFolderPath("CommonDesktopDirectory")
function Remove-Shortcuts($path) {
  $shortcuts = Get-ChildItem -Path $path -Filter *.lnk
  foreach ($shortcut in $shortcuts) {
    Remove-Item $shortcut.FullName -Force
  }
}

Remove-Shortcuts -path $userDesktopPath
Remove-Shortcuts -path $publicDesktopPath