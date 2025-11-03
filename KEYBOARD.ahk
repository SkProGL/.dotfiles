#Requires AutoHotkey v2.0+

; Remap Caps Lock to Escape
CapsLock::Esc

; Shift+CapsLock -> tilde (~)
+CapsLock::Send "~"

; Swap ; and Enter, including Shift variants

; Normal semicolon (;) -> Enter
SC027::Send("{Enter}")

; Shift+semicolon (:) -> Shift+Enter
+SC027::Send("+{Enter}")

; Enter -> semicolon (;)
Enter::Send(";")

; Shift+Enter -> colon (:)
+Enter::Send(":")


; step := 20  ; Number of pixels to move each time

; ^Up::    MouseMove(0, -step, 0, "R")  ; Ctrl+Up moves mouse up
; ^Down::  MouseMove(0, step, 0, "R")   ; Ctrl+Down moves mouse down
; ^Left::  MouseMove(-step, 0, 0, "R")  ; Ctrl+Left moves mouse left
; ^Right:: MouseMove(step, 0, 0, "R")   ; Ctrl+Right moves mouse right

; Left click on Ctrl + Alt + L
; ^!l::Click("left")

; Right click on Ctrl + Alt + R
; ^!SC027::Click("right")  ; Ctrl + Alt + ; (semicolon) triggers right click
