WebBrowser := "Google Chrome"
Mail := "Outlook"
FileBrowser := "FreeCommander"
IM := "Skype"
Terminal := "Putty"
Editor := "Notepad++"


CurrentUser := "BRN"
DefaultLocation := "Cleaning and Staging"
DefaultFirstNote := "Repair order started."

#Persistent
SetCapsLockState, Off
SetCapsLockState, AlwaysOff

SetTitleMatchMode, Slow
DetectHiddenWindows, On

!^r::Reload

; Launchy Override
#space::#F12

; Minimize (Hide)
Capslock & h::WinMinimize, A

; SAP Templates
; ----------------------------------------------
#z::
FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm
SendInput %CurrentDateTime% %A_UserName%:`r
Return

#x::
InputBox, ModelNumber, ModelNumber, "Model Number",,,,,,,,DefaultModel
InputBox, SerialNumber, SerialNumber, "Serial Number",,,,,,,,DefaultSerial
InputBox, Reason, Reason, "Reason",,,,,,,,DefaultReason
SendInput %ModelNumber% SN: %SerialNumber% - %Reason%`r`r

FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm
SendInput %CurrentDateTime% %A_UserName%:`r
Return

;#c::
;SetControlDelay -1
;;ControlClick, ReBarWindow321, Sumatra PDF,,,, NA
;;ControlFocus, Edit1, SAP Easy Access
;ControlSend, Edit1, iw73{Enter}, SAP Easy Access
;Sleep, 2000
;;ControlFocus, x298 y465, Display Service Order: Selection of Orders
;ControlSend, , ^a{Delete}, ahk_id SAP_FRONTEND_SESSION
;TrayTip, , Activating
;Return
; ----------------------------------------------

; Temporary, Copy csv files to data directory to ease debugging:
Capslock & d::FileCopy,C:\Kistler\Maxymos Upgrade\NC Examples Error\CurrentTest\*.csv,C:\Data

; Focus WebBrowser:
Capslock & w::RunOrActivate("C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe", "Google Chrome")

; Focus Skype
Capslock & s::RunOrActivate("C:\Program Files (x86)\Skype\Phone\Skype.exe", "Skype")

; Focus Editor
Capslock & a::RunOrActivate("C:\Program Files (x86)\notepad++\notepad++", "notepad++")

; Focus File Browser
Capslock & e::RunOrActivate("C:\Program Files (x86)\FreeCommander XE\freecommander.exe", "FreeCommander XE")

; Focus Mail
Capslock & q::RunOrActivate("C:\Program Files (x86)\Microsoft Office\Office14\outlook.exe", "Microsoft Outlook")

; Focus Terminal
Capslock & t::RunOrActivate("C:\Program Files (x86)\PuTTY\putty.exe", "PuTTy")


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
		TrayTip, , Activating Window Title "%WinTitle%" (%TargetNameOnly%)
		WinActivate, %WinTitle%
	}
	Else
	{
		WinWait, ahk_pid %PID%, , 3
		TrayTip, , Activating PID %PID% (%TargetNameOnly%)
		WinActivate, ahk_pid %PID%
	}

	WinGet, winState, MinMax, A
	; If minimized then restore.
	if (winState = -1) {
		WinRestore, A
	}

	SetTimer, RunOrActivateTrayTipOff, 500
}

; Turn off the tray tip
RunOrActivateTrayTipOff:
	SetTimer, RunOrActivateTrayTipOff, off
	TrayTip
Return
