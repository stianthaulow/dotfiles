if (Test-Path -Path "$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk") {
  # Call the shortcut context menu item
  $Shell = (New-Object -ComObject Shell.Application).NameSpace("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
  $Shortcut = $Shell.ParseName("Microsoft Edge.lnk")
  # Extract the localized "Unpin from taskbar" string from shell32.dll
  $Shortcut.Verbs() | Where-Object -FilterScript { $_.Name -eq "$([WinAPI.GetStr]::GetString(5387))" } | ForEach-Object -Process { $_.DoIt() }
}