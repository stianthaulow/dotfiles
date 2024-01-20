; Send "{LWin}"
; Sleep 400
; Send "terminal"
; Sleep 400
; Send "+{F10}"
; Sleep 400
; Send "{Down}"
; Sleep 100

WinActivate("ahk_class Shell_TrayWnd")
Sleep 100
Send "+{F10}"