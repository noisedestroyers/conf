#Persistent
#SingleInstance, Force
#NoEnv
SendMode Input

SetCapsLockState, Off
SetCapsLockState, AlwaysOff

SetTitleMatchMode, Slow
DetectHiddenWindows, On

debugger(message) 
{
	;~ ToolTip, % message
	;~ sleep 100
	return
}

!^r::Reload

WebBrowser := "Google Chrome"
Mail := "Outlook"
FileBrowser := "FreeCommander"
IM := "Skype"
Terminal := "Putty"
Editor := "Notepad++"

PhoneNumber := "810-772-0414"

; Launchy Override
#space::#F12
Capslock & space::#F12
Return

; Minimize (Hide)
Capslock & h::WinMinimize, A
Return

; Phone Num:
Capslock & p::
SendInput 810 772 0414
Return

; DateTime Stamp:
Capslock & t::RunOrActivate("wt", "Windows Terminal")
;FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
;SendInput %CurrentDateTime%
Return

; Enable VPN to DTS
Capslock & v::
Run, C:\Program Files\Dell SonicWALL\Global VPN Client\SWGVC.exe -e "mobile.dtsweb.com",,hide
;ToolTip, Enable VPN
Return

; Disable VPN to DTS
Capslock & b::
Run, C:\Program Files\Dell SonicWALL\Global VPN Client\SWGVC.exe -d "mobile.dtsweb.com",,hide
;ToolTip, Disable VPN
Return

; Edit AHK Script
Capslock & r::
Run, C:\Program Files\Notepad++\notepad++.exe c:\users\nathan.brown\Documents\AutoHotKey.ahk
Return

; Edit AHK Script
Capslock & n::
Run, ncpa.cpl
Return

Capslock & Escape::
Run, C:\Program Files\sysinternals\procexp.exe
Return

; Temporary, Copy csv files to data directory to ease debugging:
;Capslock & d::FileCopy,C:\Kistler\Maxymos Upgrade\NC Examples Error\CurrentTest\*.csv,C:\Data

; Focus WebBrowser:
Capslock & w::RunOrActivate("C:\Program Files\Mozilla Firefox\Firefox.exe", "Firefox")

; Focus Skype
Capslock & s::RunOrActivate("C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe", "Skype")

; Focus ConEmu
Capslock & c::^`
Return

; Focus Editor
Capslock & a::RunOrActivate("C:\Program Files\notepad++\notepad++", "notepad++")

; Focus File Browser
Capslock & e::RunOrActivate("C:\Program Files (x86)\FreeCommander XE\freecommander.exe", "FreeCommander XE")

; Focus Mail
Capslock & q::RunOrActivate("C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE", "Outlook")

; Focus WebBrowser:
Capslock & z::RunOrActivate("C:\Program Files (x86)\Microsoft Office\root\Office16\ONENOTE.EXE", "OneNote")

; Focus WebBrowser:



; Focus Terminal
;Capslock & t::RunOrActivate("C:\Program Files (x86)\PuTTY\putty.exe", "PuTTy")


; ===========================================================================
; Run a program or switch to it if already running.
;    Target - Program to run. E.g. Calc.exe or C:\Progs\Bobo.exe
;    WinTitle - Optional title of the window to activate.  Programs like
;       MS Outlook might have multiple windows open (main window and email
;       windows).  This parm allows activating a specific window.
; ===========================================================================
RunOrActivate(Target, WinTitle = "")
{
	; Get the filename without a path
	SplitPath, Target, TargetNameOnly

	Process, Exist, %TargetNameOnly%
	If ErrorLevel > 0
		PID = %ErrorLevel%
	Else
		Run, %Target%, , , PID

	; At least one app (Seapine TestTrack wouldn't always become the active
	; window after using Run), so we always force a window activate.
	; Activate by title if given, otherwise use PID.
	If WinTitle <> 
	{
		SetTitleMatchMode, 2
		WinWait, %WinTitle%, , 3
		;TrayTip, , Activating Window Title "%WinTitle%" (%TargetNameOnly%)
		WinActivate, %WinTitle%
	}
	Else
	{
		WinWait, ahk_pid %PID%, , 3
		;TrayTip, , Activating PID %PID% (%TargetNameOnly%)
		WinActivate, ahk_pid %PID%
	}

	WinGet, winState, MinMax, A
	; If minimized then restore.
	if (winState = -1) {
		WinRestore, A
	}

	;SetTimer, RunOrActivateTrayTipOff, 500
}

; Turn off the tray tip
RunOrActivateTrayTipOff:
	SetTimer, RunOrActivateTrayTipOff, off
	TrayTip
Return

#c::ExitApp
Return

; Globals
DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
 global CurrentDesktop, DesktopCount
 ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
 IdLength := 32
 SessionId := getSessionId()
 if (SessionId) {
 RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
 if (CurrentDesktopId) {
 IdLength := StrLen(CurrentDesktopId)
 }
 }
 ; Get a list of the UUIDs for all virtual desktops on the system
 RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
 if (DesktopList) {
 DesktopListLength := StrLen(DesktopList)
 ; Figure out how many virtual desktops there are
 DesktopCount := DesktopListLength / IdLength
 }
 else {
 DesktopCount := 1
 }
 ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
 i := 0
 while (CurrentDesktopId and i < DesktopCount) {
 StartPos := (i * IdLength) + 1
 DesktopIter := SubStr(DesktopList, StartPos, IdLength)
 OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
 ; Break out if we find a match in the list. If we didn't find anything, keep the
 ; old guess and pray we're still correct :-D.
 if (DesktopIter = CurrentDesktopId) {
 CurrentDesktop := i + 1
 OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
 break
 }
 i++
 }
}
;
; This functions finds out ID of current session.
;
getSessionId()
{
 ProcessId := DllCall("GetCurrentProcessId", "UInt")
 if ErrorLevel {
 OutputDebug, Error getting current process id: %ErrorLevel%
 return
 }
 OutputDebug, Current Process Id: %ProcessId%
 DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
 if ErrorLevel {
 OutputDebug, Error getting session id: %ErrorLevel%
 return
 }
 OutputDebug, Current Session Id: %SessionId%
 return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop)
{
 global CurrentDesktop, DesktopCount
 ; Re-generate the list of desktops and where we fit in that. We do this because
 ; the user may have switched desktops via some other means than the script.
 mapDesktopsFromRegistry()
 ; Don't attempt to switch to an invalid desktop
 if (targetDesktop > DesktopCount || targetDesktop < 1) {
 OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
 return
 }
 ; Go right until we reach the desktop we want
 while(CurrentDesktop < targetDesktop) {
 Send ^#{Right}
 CurrentDesktop++
 OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
 }
 ; Go left until we reach the desktop we want
 while(CurrentDesktop > targetDesktop) {
 Send ^#{Left}
 CurrentDesktop--
 OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
 }
 
	Progress, b fs18 zh0 w100, %CurrentDesktop%, , , Consolas
	Sleep, 300
	Progress, Off
}
;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^d
 DesktopCount++
 CurrentDesktop = %DesktopCount%
 OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^{F4}
 DesktopCount--
 CurrentDesktop--
 OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
; User config!
; This section binds the key combo to the switch/create/delete actions
CapsLock & 1::switchDesktopByNumber(1)
CapsLock & 2::switchDesktopByNumber(2)
CapsLock & 3::switchDesktopByNumber(3)
CapsLock & 4::switchDesktopByNumber(4)
CapsLock & 5::switchDesktopByNumber(5)
CapsLock & 6::switchDesktopByNumber(6)
CapsLock & 7::switchDesktopByNumber(7)
CapsLock & 8::switchDesktopByNumber(8)
CapsLock & 9::switchDesktopByNumber(9)
CapsLock & k::switchDesktopByNumber(CurrentDesktop + 1)
CapsLock & j::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & s::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & a::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & c::createVirtualDesktop()
;CapsLock & d::deleteVirtualDesktop()
; Alternate keys for this config. Adding these because DragonFly (python) doesn't send CapsLock correctly.
;^!1::switchDesktopByNumber(1)
;^!2::switchDesktopByNumber(2)
;^!3::switchDesktopByNumber(3)
;^!4::switchDesktopByNumber(4)
;^!5::switchDesktopByNumber(5)
;^!6::switchDesktopByNumber(6)
;^!7::switchDesktopByNumber(7)
;^!8::switchDesktopByNumber(8)
;^!9::switchDesktopByNumber(9)
;^!n::switchDesktopByNumber(CurrentDesktop + 1)
;^!p::switchDesktopByNumber(CurrentDesktop - 1)
;^!s::switchDesktopByNumber(CurrentDesktop + 1)
;^!a::switchDesktopByNumber(CurrentDesktop - 1)
;^!c::createVirtualDesktop()
;^!d::deleteVirtualDesktop()
