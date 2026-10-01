
#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; SMART WINDOW SWITCHER
; AutoHotkey v2 - works locally
; ==========================================

; Update this URL to your actual Wingspan URL.
WINGSPAN_URL := "PASTE_YOUR_WINGSPAN_URL_HERE"

; Ctrl + Alt + M: Moodle / SLMS
^!m:: {
    if WinExist("Moodle ahk_exe chrome.exe") {
        WinActivate
    } else {
        Run "https://slms.ssodl.edu.in/"
    }
}

; Ctrl + Alt + W: Wingspan
^!w:: {
    if WinExist("Wingspan ahk_exe chrome.exe") {
        WinActivate
    } else if (WINGSPAN_URL != "https://ssodl.onwingspan.com/") {
        Run WINGSPAN_URL
    } else {
        MsgBox "Please add your Wingspan URL to the script first."
    }
}

; Ctrl + Alt + C: Google Chrome
^!c:: {
    if WinExist("ahk_exe chrome.exe") {
        WinActivate
    } else {
        Run "chrome.exe"
    }
}

; Ctrl + Alt + E: Microsoft Excel
^!e:: {
    if WinExist("ahk_exe EXCEL.EXE") {
        WinActivate
    } else {
        try {
            Run "excel.exe"
        } catch {
            MsgBox "Excel could not be launched. Check whether it is installed."
        }
    }
}

; Ctrl + Alt + N: Notepad
^!n:: {
    if WinExist("ahk_exe notepad.exe") {
        WinActivate
    } else {
        Run "notepad.exe"
    }
}