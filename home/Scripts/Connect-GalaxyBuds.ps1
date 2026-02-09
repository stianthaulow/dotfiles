param(
    [switch]$Debug
)

function Log([string]$msg) {
    if ($Debug) { Write-Host ("[UIA] {0}" -f $msg) }
}

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$DeviceTimeoutMs = 1000
$ButtonTimeoutMs = 1000
$TraversalMaxNodes = 100

$SettingsUri = "ms-settings:bluetooth"
$DeviceName = "Galaxy Buds Pro (5270)"

Log "Launching Settings: $SettingsUri"
Start-Process $SettingsUri
Start-Sleep -Milliseconds 750

function Get-UiAName($el) {
    try { return $el.Current.Name } catch { return $null }
}

function Get-UiAControlType($el) {
    try { return $el.Current.ControlType } catch { return $null }
}

function Find-DescendantByPredicate($container, $timeoutMs, $maxNodes, [string]$label, [scriptblock]$predicate) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
    $stack = New-Object System.Collections.Stack
    $visited = 0

    Log ("{0}: scan start (timeout={1}ms, maxNodes={2})" -f $label, $timeoutMs, $maxNodes)

    $first = $null
    try { $first = $walker.GetFirstChild($container) } catch { $first = $null }
    $child = $first
    while ($child) {
        $stack.Push($child)
        try { $child = $walker.GetNextSibling($child) } catch { $child = $null }
    }

    while ($stack.Count -gt 0) {
        if ($sw.ElapsedMilliseconds -ge $timeoutMs) {
            Log ("{0}: timeout after {1}ms (visited={2})" -f $label, $sw.ElapsedMilliseconds, $visited)
            return $null
        }
        if ($visited -ge $maxNodes) {
            Log ("{0}: maxNodes reached (visited={1}, elapsed={2}ms)" -f $label, $visited, $sw.ElapsedMilliseconds)
            return $null
        }

        $el = $stack.Pop()
        $visited++

        $ok = $false
        try { $ok = & $predicate $el } catch { $ok = $false }
        if ($ok) {
            Log ("{0}: match (visited={1}, elapsed={2}ms)" -f $label, $visited, $sw.ElapsedMilliseconds)
            return $el
        }

        # push children
        $c = $null
        try { $c = $walker.GetFirstChild($el) } catch { $c = $null }
        while ($c) {
            $stack.Push($c)
            try { $c = $walker.GetNextSibling($c) } catch { $c = $null }
        }
    }

    Log ("{0}: no match (visited={1}, elapsed={2}ms)" -f $label, $visited, $sw.ElapsedMilliseconds)
    $null
}

function Get-DeviceCardFromMatch($matchEl) {
    if (-not $matchEl) { return $null }

    $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
    $cur = $matchEl

    while ($cur) {
        $ct = $null
        try { $ct = $cur.Current.ControlType } catch {}

        if ($ct -eq [System.Windows.Automation.ControlType]::ListItem -or
            $ct -eq [System.Windows.Automation.ControlType]::Group -or
            $ct -eq [System.Windows.Automation.ControlType]::Pane) {
            return $cur
        }

        $cur = $walker.GetParent($cur)
    }

    $null
}

function Get-TopLevelWindows() {
    $winCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Window
    )

    [System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children, $winCond)
}

function Find-SettingsWindow($timeoutMs = 15000) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt $timeoutMs) {
        $wins = @(Get-TopLevelWindows)
        $winsData = $wins | ForEach-Object {
            $pname = $null
            try { $pname = (Get-Process -Id $_.Current.ProcessId -ErrorAction Stop).ProcessName } catch {}

            [PSCustomObject]@{
                El      = $_
                Name    = $_.Current.Name
                Process = $pname
            }
        }

        # Strongly prefer the real Settings app host processes, regardless of title.
        $settingsProc = @("SystemSettings", "ApplicationFrameHost")
        $settingsWins = $winsData | Where-Object { $_.Name -and ($settingsProc -contains $_.Process) }
        if ($settingsWins.Count -gt 0) {
            $bestSettings =
            ($settingsWins | Where-Object { $_.Name -match '(?i)bluetooth|devices' } | Select-Object -First 1) ??
            ($settingsWins | Select-Object -First 1)

            if ($bestSettings) { return $bestSettings.El }
        }

        # Fallback if Settings isn't visible yet: only then consider title matches, but avoid common false positives (browser shells).
        $excludedProcRegex = '(?i)^(chrome|msedge|firefox|pwsh|powershell|code)$'
        $candidates = $winsData | Where-Object {
            $_.Name -and ($_.Name -match '(?i)settings|bluetooth|devices') -and ($_.Process -notmatch $excludedProcRegex)
        }

        $best =
        ($candidates | Where-Object { $_.Name -match '(?i)bluetooth|devices' } | Select-Object -First 1) ??
        ($candidates | Select-Object -First 1)

        if ($best) { return $best.El }

        Start-Sleep -Milliseconds 250
    }

    $null
}

function Close-SettingsWindow($win) {
    if (-not $win) { return }

    Log "Closing Settings window"

    # Preferred: UIA WindowPattern.Close()
    try {
        $wp = [System.Windows.Automation.WindowPattern]$win.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)
        if ($wp) {
            $wp.Close()
            return
        }
    }
    catch {}
}

$win = Find-SettingsWindow
if (-not $win) {
    $dump = @(Get-TopLevelWindows | Select-Object -First 30 | ForEach-Object {
            $pname = $null
            try { $pname = (Get-Process -Id $_.Current.ProcessId -ErrorAction Stop).ProcessName } catch {}
            [PSCustomObject]@{
                Name      = $_.Current.Name
                ClassName = $_.Current.ClassName
                ProcessId = $_.Current.ProcessId
                Process   = $pname
            }
        })

    $dump | Format-Table -AutoSize | Out-String | Write-Host
    throw "Settings window not found. See candidate windows above; we can tune the match."
}

Log ("Settings window: '{0}'" -f (Get-UiAName $win))

$deviceBase = ($DeviceName -replace '\s*\(.*\)\s*$', '').Trim()
$escaped = [regex]::Escape($deviceBase)
$match = Find-DescendantByPredicate $win $DeviceTimeoutMs $TraversalMaxNodes "device-name" {
    param($el)
    $n = Get-UiAName $el
    if (-not $n) { return $false }
    return ($n -match $escaped)
}

$device = Get-DeviceCardFromMatch $match
if (-not $device) {
    throw "Device '$DeviceName' not found."
}

Log ("Device match: '{0}'" -f (Get-UiAName $device))

$deviceText = (Get-UiAName $device)
if (-not $deviceText) { $deviceText = "" }

# Only attempt to connect if Settings reports the device as "Not connected".
if ($deviceText -notmatch '(?i)\bstate\b.*\bnot\s+connected\b') {
    Log "Device is not in 'State Not connected' - closing Settings and exiting"
    Close-SettingsWindow $win
    exit 0
}

$btn = Find-DescendantByPredicate $device $ButtonTimeoutMs 12000 "connect-button" {
    param($el)
    $ct = Get-UiAControlType $el
    if ($ct -ne [System.Windows.Automation.ControlType]::Button) { return $false }
    $n = Get-UiAName $el
    if (-not $n) { return $false }

    if ($n -ieq "Connect") { return $true }

    # fallback: any button with "connect" in its accessible name
    return ($n -match '(?i)\bconnect\b')
}

if (-not $btn) {
    throw "Connect button not found (timeout=${ButtonTimeoutMs}ms)."
}

Log ("Connect button: '{0}'" -f (Get-UiAName $btn))

$invoke = [System.Windows.Automation.InvokePattern]$btn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
$invoke.Invoke()

Start-Sleep -Milliseconds 150
Close-SettingsWindow $win
