$Signature = @{
    Namespace        = "WinAPI"
    Name             = "GetStr"
    Language         = "CSharp"
    UsingNamespace   = "System.Text"
    MemberDefinition = @"
[DllImport("kernel32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr GetModuleHandle(string lpModuleName);

[DllImport("user32.dll", CharSet = CharSet.Auto)]
internal static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);

public static string GetString(uint strId)
{
IntPtr intPtr = GetModuleHandle("shell32.dll");
StringBuilder sb = new StringBuilder(255);
LoadString(intPtr, strId, sb, sb.Capacity);
return sb.ToString();
}
"@
}
if (-not ("WinAPI.GetStr" -as [type])) {
Add-Type @Signature
}

$TaskBar = (New-Object -ComObject Shell.Application).NameSpace("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
$toRemove = @()

# Edge
$toRemove += $TaskBar.ParseName("Microsoft Edge.lnk")

# Microsoft Store
$toRemove += ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items()) | Where-Object { $_.Name -like "Microsoft Store" }
  
# Extract the localized "Unpin from taskbar" string from shell32.dll
foreach ($pinned in $toRemove) {
  if ($pinned) {
    Write-Debug "Removing $pinned from taskbar"
    $pinned.Verbs() | Where-Object -FilterScript { $_.Name -eq "$([WinAPI.GetStr]::GetString(5387))" } | ForEach-Object -Process { $_.DoIt() }
  }
}