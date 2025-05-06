#NoEnv  		; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

CoordMode, Mouse, Screen

#Include StringUtils.ahk
#Include ArrayUtils.ahk

IfNotEqual, A_IsCompiled, 1
{
	
}

Menu, Tray, Tip, Window Menu

;--------------------------------------------------------------------------------
; Configuration
SplitPath A_ScriptFullPath, , ScriptFilePath , , ScriptFileNameNoExt
IconLibraryFileName := ScriptFilePath . "\" . ScriptFileNameNoExt . ".icl"

; Initialise Log
LogFile := A_Temp . "\" . ScriptFileNameNoExt . ".log"
LogText("--------------------------------------------------------------------------------")
LogText("Starting...")

MenuTitle = Window Menu

SetFormat, float, 0.0
SetBatchLines, 10ms 
SetTitleMatchMode, 2

;--------------------------------------------------------------------------------
; System Information
SysGet, MIW_CaptionHeight, 4 ; SM_CYCAPTION
SysGet, MIW_BorderHeight, 5 ; SM_CXBORDER
LogText("MIW_CaptionHeight: " MIW_CaptionHeight)
LogText("MIW_BorderHeight: " MIW_BorderHeight)

ws_MinHeight := MIW_CaptionHeight + (MIW_BorderHeight * 2)
LogText("ws_MinHeight: " ws_MinHeight)

RollupList := Object()

IconIndexes := Object()
IconIndexes.Insert("MOVESIZE_COLUMN_CENTRE")
IconIndexes.Insert("MOVESIZE_COLUMN_LEFT")
IconIndexes.Insert("MOVESIZE_COLUMN_RIGHT")
IconIndexes.Insert("MOVESIZE_COMMON_MEDIUM")
IconIndexes.Insert("MOVESIZE_COMMON_OPTIMUM")
IconIndexes.Insert("MOVESIZE_COMMON_SMALL")
IconIndexes.Insert("MOVESIZE_COMMON_SUBOPTIMUM")
IconIndexes.Insert("MOVESIZE_COMMON_TINY")
IconIndexes.Insert("MOVE_CENTRE")
IconIndexes.Insert("MOVE_CORNER_BOTTOMLEFT")
IconIndexes.Insert("MOVE_CORNER_BOTTOMRIGHT")
IconIndexes.Insert("MOVE_CORNER_TOPLEFT")
IconIndexes.Insert("MOVE_CORNER_TOPRIGHT")
IconIndexes.Insert("POSITION_TRANSPARENCY0")
IconIndexes.Insert("POSITION_TRANSPARENCY25")
IconIndexes.Insert("POSITION_TRANSPARENCY50")
IconIndexes.Insert("POSITION_TRANSPARENCY75")
IconIndexes.Insert("POSITION_ZORDER_SENDTOBACK")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTOFF")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTON")
IconIndexes.Insert("POSITION_ZORDER_TOPMOSTTOGGLE")
IconIndexes.Insert("SIZE_COMMON_ROLLUP")

;--------------------------------------------------------------------------------
; Initialisation
SysGet, monitorCount, MonitorCount

;--------------------------------------------------------------------------------
; Build Menu
Menu, WindowMenu, Add, %MenuTitle%, NullHandler
Menu, WindowMenu, Icon, %MenuTitle%, Shell32.dll, 20

; Standard Window Sizes
Menu, WindowMenu, Add
AddWindowMenuItem("&Optimum Size", "OptimumSizeHandler", "MOVESIZE_COMMON_OPTIMUM")
AddWindowMenuItem("Su&b-Optimum Size", "SubOptimumSizeHandler", "MOVESIZE_COMMON_SUBOPTIMUM")
AddWindowMenuItem("M&edium Size", "MediumSizeHandler", "MOVESIZE_COMMON_MEDIUM")
AddWindowMenuItem("Sma&ll Size", "SmallSizeHandler", "MOVESIZE_COMMON_SMALL")
AddWindowMenuItem("T&iny Size", "TinySizeHandler", "MOVESIZE_COMMON_TINY")
Menu, WindowMenu, Add
AddWindowMenuItem("Roll&up", "RollupHandler", "SIZE_COMMON_ROLLUP")

; Move to known columns of the Screen
Menu, WindowMenu, Add
AddWindowMenuItem("&Left Column", "MoveColumnLeftHandler", "MOVESIZE_COLUMN_LEFT")
AddWindowMenuItem("Ce&ntre Column", "MoveColumnCentreHandler", "MOVESIZE_COLUMN_CENTRE")
AddWindowMenuItem("&Right Column", "MoveColumnRightHandler", "MOVESIZE_COLUMN_RIGHT")
; Menu, WindowMenu, Add, Colum&n, :ColumnMenu

; Multi-Monitor spanning
if (monitorCount > 1)
{
    Menu, WindowMenu, Add
    AddWindowMenuItem("S&pan Monitor Width", "SpanMonitorWidthHandler", "MOVESIZE_SPAN_WIDTH")
    AddWindowMenuItem("S&pan Monitor Height", "SpanMonitorHeightHandler", "MOVESIZE_SPAN_HEIGHT")
    AddWindowMenuItem("S&pan All Monitors", "SpanAllMonitors", "MOVESIZE_SPAN_ALL")
}

; Move to Corners
Menu, WindowMenu, Add
AddWindowMenuItem("Move &Centre", "CentreHandler", "MOVE_CENTRE")
AddWindowMenuItem("Move &Top Left", "MoveTopLeftHandler", "MOVE_CORNER_TOPLEFT")
AddWindowMenuItem("Move &Top Right", "MoveTopRightHandler", "MOVE_CORNER_TOPRIGHT")
AddWindowMenuItem("Move &Bottom Left", "MoveBottomLeftHandler", "MOVE_CORNER_BOTTOMLEFT")
AddWindowMenuItem("Move &Bottom Right", "MoveBottomRightHandler", "MOVE_CORNER_BOTTOMRIGHT")
; Menu, WindowMenu, Add, &Corner, :CornerMenu

; Topmost handling
Menu, WindowMenu, Add
AddWindowMenuItem("Set TopMost O&n", "TopHandlerSet", "POSITION_ZORDER_TOPMOSTON")
AddWindowMenuItem("Set TopMost O&ff", "TopHandlerUnset", "POSITION_ZORDER_TOPMOSTOFF")
AddWindowMenuItem("&Toggle TopMost", "TopHandlerToggle", "POSITION_ZORDER_TOPMOSTTOGGLE")
;Menu, WindowMenu, Add, &Top, :TopMenu

; Transparency
Menu, WindowMenu, Add
AddWindowMenuItem("Set Transparency &75%", "TransparencySet75", "POSITION_TRANSPARENCY75")
AddWindowMenuItem("Set Transparency &50%", "TransparencySet50", "POSITION_TRANSPARENCY50")
AddWindowMenuItem("Set Transparency &25%", "TransparencySet25", "POSITION_TRANSPARENCY25")
AddWindowMenuItem("Set Transparency &0%", "TransparencySet0", "POSITION_TRANSPARENCY0")

; Send to back
Menu, WindowMenu, Add
AddWindowMenuItem("Send to Bac&k", "SendToBackHandler", "POSITION_ZORDER_SENDTOBACK")

; Cancel menu
Menu, WindowMenu, Add
Menu, WindowMenu, Add, &Cancel, NullHandler

; This line will unroll any rolled up windows if the script exits
; for any reason:
OnExit, ExitSub

return  ; End of script's auto-execute section.

;--------------------------------------------------------------------------------
; LogText - Debug Text to a file
LogText(text)
{
	global LogFile
	
	;IfEqual, A_IsCompiled, 1
	;{
	;	return
	;}
	
	FormatTime now,, yyy-MM-dd HH:mm.ss
	FileAppend %now% %text%`n, %LogFile%
}

;--------------------------------------------------------------------------------
; AddWindowMenuItem - Add a Menu Item to the main Window Menu
AddWindowMenuItem(text, handler, iconName)
{
	global WindowMenu
	global IconLibraryFileName
	
	Menu, WindowMenu, Add, %text%, %handler%
	
	iconIndex := GetIconIndex(iconName)
	if (iconIndex > 0)
	{
		Menu, WindowMenu, Icon, %text%,  %IconLibraryFileName%, %iconIndex%
	}
}

;--------------------------------------------------------------------------------
; GetIconIndex - Find the array index of a named icon
GetIconIndex(iconName)
{
	global IconIndexes
	
	;LogText("Looking for Icon: " . iconName)
	
	for index, element in IconIndexes
	{
		If (element = iconName)
		{
			;LogText("Found at " . index)
			return index
		}
	}
	
	return 0
}

;--------------------------------------------------------------------------------
; SetWindowPosByGutter - Set the Window position including a gutter
SetWindowByGutter(theWindow, gutterSize)
{
	LogText("gutterSize: " . gutterSize)
	
	winMonitor := GetMonitorForWindow(theWindow)
	LogText("winMonitor: " . winMonitor)

	SysGet, winMonitorArea, MonitorWorkArea, %winMonitor%
	winMonitorAreaWidth := Abs(winMonitorAreaRight - winMonitorAreaLeft)
	winMonitorAreaHeight := Abs(winMonitorAreaBottom - winMonitorAreaTop)
	LogText("winMonitorArea: " . winMonitorAreaLeft . ", " . winMonitorAreaTop . ", " . winMonitorAreaBottom . ", " . winMonitorAreaRight . " [" . winMonitorAreaWidth . "," . winMonitorAreaHeight . "]")
	
	WinRestore ahk_id %theWindow%
	;LogText("Position/Size: " . winMonitorAreaLeft + gutterSize . ", " . winMonitorAreaTop + gutterSize . ", " . (winMonitorAreaWidth - (gutterSize * 2)) . ", " . (winMonitorAreaHeight - (gutterSize * 2)))
	WinMove ahk_id %theWindow%, , winMonitorAreaLeft + gutterSize, winMonitorAreaTop + gutterSize, (winMonitorAreaWidth - (gutterSize * 2)), (winMonitorAreaHeight - (gutterSize * 2))
}

;--------------------------------------------------------------------------------
; ShowMenu - Show the Window Control Menu
ShowMenu(theWindow)
{
	global MenuTitle
	
	; Get Process Name, Window Title and Size / Position
	WinGet, theProcess, ProcessName, ahk_id %theWindow%
	WinGet, theProcessFilePath, ProcessPath, ahk_id %theWindow%
	WinGetTitle, theTitle, ahk_id %theWindow%
	WinGetPos, windowX, windowY, windowWidth, windowHeight, ahk_id %theWindow%

	windowMonitor := GetMonitorForWindow(theWindow)
	
	; Build Window Details
	newMenuTitle := theTitle . " (" . theProcess . ") [" . windowX . ":" . windowY . ":" . windowWidth . ":" . windowHeight . ":" . windowMonitor . "]"

	; Change Menu
	if (newMenuTitle <> MenuTitle)
	{
		MenuTitle := newMenuTitle
		Menu, WindowMenu, Rename, 1&,  %MenuTitle%
	}
	Menu, WindowMenu, Icon, 1&, %theProcessFilePath%, 0
	
	; Enable / Disable as appropriate
	if (IsWindowTopMost(theWindow))
	{
		Menu, WindowMenu, Disable, Set TopMost O&n
		Menu, WindowMenu, Enable, Set TopMost O&ff
	}
	else
	{
		Menu, WindowMenu, Enable, Set TopMost O&n
		Menu, WindowMenu, Disable, Set TopMost O&ff
	}
	
	; Show Popup Menu
	Menu, WindowMenu, Show
}

;--------------------------------------------------------------------------------
; IsWindowTopMost - Detect if a window is set on top
IsWindowTopMost(theWindow)
{
	WinGet, winStyle, ExStyle, ahk_id %theWindow%
	if (winStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
	{
		return true
	}
	
	return false
}

;--------------------------------------------------------------------------------
; RollupWindow - Roll up a window to just its title bar
RollupWindow(theWindow)
{
	global RollupList
	global ws_MinHeight
	
	for ruWindowId, ruHeight in RollupList
	{
		IfEqual, ruWindowId, %theWindow%
		{
			WinMove, ahk_id %theWindow%,,,,, %ruHeight%
			RollupList.Delete(theWindow)
			return
		}
	}

	WinGetPos,,,, wsHeight, ahk_id %theWindow%
	RollupList[theWindow] := wsHeight

	WinMove, ahk_id %theWindow%,,,,, %ws_MinHeight%
}

;--------------------------------------------------------------------------------
; GetMonitorAt - Get the index of the monitor containing the specified x and y co-ordinates. 
GetMonitorAt(x, y, defaultMonitor = -1) 
{
    SysGet, m, MonitorCount
	
	LogText("GetMonitorAt: Window: " . x . ", " . y)
	
    ; Iterate through all monitors.
    Loop, %m%
    {
		; Check if the window is on this monitor.
        SysGet, Mon, Monitor, %A_Index%
		
		monDetails := A_Index . ": Left: " . MonLeft . ", Right: " . MonRight . ", Top: " . MonTop . ", Bottom: " . MonBottom
		LogText("Monitor: " . monDetails)
		
        if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
            return A_Index
    }

    return defaultMonitor
}

;--------------------------------------------------------------------------------
; GetMonitorForWindow - Get the index of the monitor containing the specified window ahk_id
GetMonitorForWindow(theWindow)
{
	WinGetPos, windowX, windowY, windowWidth, windowHeight, ahk_id %theWindow%
	
	windowMonitor := GetMonitorAt(windowX, windowY)
	if (windowMonitor < 0)
	{
		midX := windowX + (windowWidth / 2)
		midY := windowY + (windowHeight / 2)
		
		windowMonitor := GetMonitorAt(midX, midY)
	}
	
	return windowMonitor
}

;--------------------------------------------------------------------------------
; LABELS - Handlers
;--------------------------------------------------------------------------------

OptimumSizeHandler:
SetWindowByGutter(activeWindow, 30)
return

SubOptimumSizeHandler:
SetWindowByGutter(activeWindow, 60)
return

MediumSizeHandler:
SetWindowByGutter(activeWindow, 90)
return

SmallSizeHandler:
SetWindowByGutter(activeWindow, 120)
return

TinySizeHandler:
SetWindowByGutter(activeWindow, 150)
return

;---------------------------------------
SpanMonitorWidthHandler:
spanWidth := 0
spanHeight := 0

SysGet, monitorCount, MonitorCount

Loop, %monitorCount%
{
    ; Check if the window is on this monitor.
    SysGet, Mon, Monitor, %A_Index%

    monDetails := A_Index . ": Left: " . MonLeft . ", Right: " . MonRight . ", Top: " . MonTop . ", Bottom: " . MonBottom
    LogText("Monitor: " . monDetails)

    if (monTop == 0)
    {
        if (monRight > spanWidth)
            spanWidth := monRight

        if (spanHeight == 0 || monBottom < spanHeight)
            spanHeight := monBottom
    }
    
    LogText("Span: Width: " . spanWidth . " height: " . spanheight)
}

WinRestore ahk_id %activeWindow%
WinMove ahk_id %activeWindow%, , 0, 0, spanWidth, spanheight

return

;---------------------------------------
SpanMonitorHeightHandler:
spanLeft := 0
spanTop := 0
spanWidth := 0
spanHeight := 0

winMonitor := GetMonitorForWindow(theWindow)
spanLeft := winMonitorLeft

Loop, %monitorCount%
{
    ; Check if the window is on this monitor.
    SysGet, Mon, Monitor, %A_Index%

    LogText("Mon: " . A_Index . ": Left: " . MonLeft . ", Right: " . MonRight . ", Top: " . MonTop . ", Bottom: " . MonBottom)
    
    if (monLeft == spanLeft)
    {
        if (monTop < spanTop)
            spanTop := monTop

        if (monBottom > spanHeight)
            spanHeight := monBottom

        if (spanWidth == 0 || monRight < spanWidth)
            spanWidth := monRight
    }
    
    LogText("Span: Width: " . spanWidth . " height: " . spanheight)
}

WinMove ahk_id %activeWindow%, , spanLeft, spanTop, spanWidth, spanheight

return

;---------------------------------------
SpanAllMonitors:
spanWidth := 0
spanHeight := 0

Loop, %monitorCount%
{
    ; Check if the window is on this monitor.
    SysGet, Mon, Monitor, %A_Index%

    LogText("Mon: " . A_Index . ": Left: " . MonLeft . ", Right: " . MonRight . ", Top: " . MonTop . ", Bottom: " . MonBottom)

    if (spanHeight == 0 || monBottom < spanHeight)
        spanHeight := monBottom

    if (spanWidth == 0 || monRight < spanWidth)
        spanWidth := monRight
    
    LogText("Span: Width: " . spanWidth . " height: " . spanheight)
}

WinMove ahk_id %activeWindow%, , 0, 0, spanWidth, spanheight

return

CentreHandler:
winMonitor := GetMonitorForWindow(activeWindow)

SysGet, winMonitorArea, MonitorWorkArea, %winMonitor%
winMonitorAreaWidth := Abs(winMonitorAreaRight - winMonitorAreaLeft)
winMonitorAreaHeight := Abs(winMonitorAreaBottom - winMonitorAreaTop)
LogText("winMonitorArea: " . winMonitorAreaLeft . ", " . winMonitorAreaTop . ", " . winMonitorAreaBottom . ", " . winMonitorAreaRight . " [" . winMonitorAreaWidth . "," . winMonitorAreaHeight . "]")

LogText("Position: " . ((winMonitorAreaRight - winMonitorAreaLeft) / 2) - (activeWindowWidth / 2) . ", " . ((winMonitorAreaBottom - winMonitorAreaTop) / 2) - (activeWindowHeight / 2))
WinMove , ahk_id %activeWindow%, , winMonitorAreaLeft + (winMonitorAreaWidth / 2) - (activeWindowWidth / 2), winMonitorAreaTop + (winMonitorAreaHeight / 2) - (activeWindowHeight / 2)
WinActivate, ahk_id %activeWindow%
WinShow, ahk_id %activeWindow%
return

MoveTopLeftHandler:
SysGet, MonPrimary, MonitorWorkArea
WinMove, ahk_id %activeWindow%, , MonPrimaryLeft, MonPrimaryTop
return

MoveTopRightHandler:
SysGet, MonPrimary, MonitorWorkArea
WinGetPos,,, Width, Height, ahk_id %activeWindow%
WinMove, ahk_id %activeWindow%, , (MonPrimaryRight - MonPrimaryLeft) - Width, MonPrimaryTop
return

MoveBottomLeftHandler:
SysGet, MonPrimary, MonitorWorkArea
WinGetPos,,, Width, Height, ahk_id %activeWindow%
WinMove, ahk_id %activeWindow%, , MonPrimaryLeft, (MonPrimaryBottom - MonPrimaryTop) - Height
return

MoveBottomRightHandler:
SysGet, MonPrimary, MonitorWorkArea
WinGetPos,,, Width, Height, ahk_id %activeWindow%
WinMove, ahk_id %activeWindow%, , (MonPrimaryRight-MonPrimaryLeft)-Width, (MonPrimaryBottom - MonPrimaryTop) - Height
return

MoveColumnLeftHandler:
gutterSize = 15
SysGet, MonPrimary, MonitorWorkArea
monitorWidth := MonPrimaryRight - MonPrimaryLeft
monitorHeight := MonPrimaryBottom - MonPrimaryTop
windowWidth := (monitorWidth - gutterSize) / 2
windowHeight := monitorHeight - (gutterSize * 2)
WinMove, ahk_id %activeWindow%, , gutterSize, gutterSize, windowWidth, windowHeight
return

MoveColumnCentreHandler:
gutterSize = 15
SysGet, MonPrimary, MonitorWorkArea
monitorWidth := MonPrimaryRight - MonPrimaryLeft
monitorHeight := MonPrimaryBottom - MonPrimaryTop
windowWidth := (monitorWidth - gutterSize) / 2
windowHeight := monitorHeight - (gutterSize * 2)
WinMove, ahk_id %activeWindow%, , (monitorWidth - gutterSize - windowWidth) / 2, gutterSize, windowWidth, windowHeight
return

MoveColumnRightHandler:
gutterSize = 15
SysGet, MonPrimary, MonitorWorkArea
monitorWidth := MonPrimaryRight - MonPrimaryLeft
monitorHeight := MonPrimaryBottom - MonPrimaryTop
windowWidth := (monitorWidth - gutterSize) / 2
windowHeight := monitorHeight - (gutterSize * 2)
WinMove, ahk_id %activeWindow%, , monitorWidth - windowWidth - gutterSize, gutterSize, windowWidth, windowHeight
return

TopHandlerSet:
WinSet, AlwaysOnTop, On, ahk_id %activeWindow%
return

TopHandlerUnset:
WinSet, AlwaysOnTop, Off, ahk_id %activeWindow%
return

TopHandlerToggle:
WinSet, AlwaysOnTop, Toggle, ahk_id %activeWindow%
return

TransparencySet75:
WinSet, Transparent, 64, ahk_id %activeWindow%
return

TransparencySet50:
WinSet, Transparent, 128, ahk_id %activeWindow%
return

TransparencySet25:
WinSet, Transparent, 192, ahk_id %activeWindow%
return

TransparencySet0:
WinSet, Transparent, 255, ahk_id %activeWindow%
return

SendToBackHandler:
WinSet, Bottom, , ahk_id %activeWindow%`
return

RollupHandler:
RollupWindow(activeWindow)
return

NullHandler:
return

ExitSub:
Loop, Parse, ws_IDList, |
{
    if A_LoopField =  ; First field in list is normally blank.
        continue      ; So skip it.
    StringTrimRight, ws_Height, ws_Window%A_LoopField%, 0
    WinMove, ahk_id %A_LoopField%,,,,, %ws_Height%
}
ExitApp  ; Must do this for the OnExit subroutine to actually Exit the script.

;--------------------------------------------------------------------------------
; WindowsKey+W
#w::
; Get Active Window
WinGet, activeWindow, ID, A
LogText("activeWindow: " . activeWindow)
ShowMenu(activeWindow)
return

;--------------------------------------------------------------------------------
; RightMouseButton
$~Rbutton::
; Get MousePos and Active Window
MouseGetPos, mouseX, mouseY, activeWindow
LogText("activeWindow: " . activeWindow)
LogText("mouseX: " . mouseX . "  mouseY: " . mouseY)

; Get active window stats
WinGetPos, activeWindowX, activeWindowY, activeWindowWidth, activeWindowHeight, ahk_id %activeWindow%
LogText("Window - X: " . activeWindowX . ", Y: " . activeWindowY . ", Width: " . activeWindowWidth . ", Height: " . activeWindowHeight)

; Get Monitor stats
mouseMonitor := GetMonitorAt(mouseX, mouseY)
if (mouseMonitor < 0)
{
	return
}

; Check for mouse click outside Monitor area and exit (prevent tray icon clicks)
SysGet, winMonitorArea, MonitorWorkArea, %mouseMonitor%
if (mouseX > winMonitorAreaRight || mouseX < winMonitorAreaLeft || mouseY < winMonitorAreaTop || mouseY > winMonitorAreaBottom)
{
    LogText("Outside Monitor Area.  mouseX: " . mouseX . ", mouseY: " . mouseY . ", monitorAreaLeft: " . winMonitorAreaLeft . ", monitorAreaRight: " . winMonitorAreaRight . ", monitorAreaTop: " . winMonitorAreaTop . ", monitorAreaBottom: " . winMonitorAreaBottom)
    return
}

; Compute position relative to window
windowMouseX := mouseX - activeWindowX
windowMouseY := mouseY - activeWindowY
LogText("windowMouseX: " . windowMouseX . "  windowMouseY: " . windowMouseY)

; Hit Test
If (windowMouseY < ws_MinHeight && windowMouseX >= (activeWindowWidth / 2) && windowMouseX <= activeWindowWidth) ; If the titlebar was clicked
{
    ShowMenu(activeWindow)
}
else
{
    LogText("Outside Caption Area.  windowMouseY: " . windowMouseY . " < " . ws_MinHeight . " OR windowMouseX: " . windowMouseX . " > " . (activeWindowWidth / 2) . " AND <= " . activeWindowWidth)
}
return
