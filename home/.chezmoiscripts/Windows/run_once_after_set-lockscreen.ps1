Write-Host "Setting lockscreen image..."
# Run in Windows PowerShell to access System.Runtime.WindowsRuntime
if ($PSVersionTable.PSEdition -eq "Core") {
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -ArgumentList $arguments -Wait -WindowStyle Hidden
  exit
}

$themePath = "$env:USERPROFILE\Theme"
$lockscreenImagePath = "$themePath\Wallpaper\login.jpg"

$tempImagePath = [System.IO.Path]::GetDirectoryName($lockscreenImagePath) + '\' + [System.Guid]::NewGuid().ToString() + [System.IO.Path]::GetExtension($lockscreenImagePath)
Copy-Item $lockscreenImagePath $tempImagePath

[Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType = WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
Function Await($WinRtTask, $ResultType) {
  $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
  $netTask = $asTask.Invoke($null, @($WinRtTask))
  $netTask.Wait(-1) | Out-Null
  $netTask.Result
}
Function AwaitAction($WinRtAction) {
  $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
  $netTask = $asTask.Invoke($null, @($WinRtAction))
  $netTask.Wait(-1) | Out-Null
}
[Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
$image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($tempImagePath)) ([Windows.Storage.StorageFile])
AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))
Remove-Item $tempImagePath
