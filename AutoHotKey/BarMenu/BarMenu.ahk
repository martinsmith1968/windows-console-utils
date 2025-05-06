#Persistent
#SingleInstance force

MenuWidth := 100
MenuColor = Silver
Hotkey, ^F11, MoveIt
Hotkey, ^F12, ExHandleAd



FileGetTime, Fileexists, barmenu
if ErrorLevel = 1
FileCreateDir, barmenu
OnTop = 1

; ==Main menu==

Menu, Tray, Add, Always on top, OnTopChange

Loop, Read, barmenu\bar.txt
{
    menuname = %A_LoopReadLine%
    Loop, Read, barmenu\%menuname%.txt
    {
        Menu, %menuname%, Add, %A_LoopReadLine%, handleinsert
    }   
    Menu, %menuname%, Add
    Menu, %menuname%, Add, Add Item, handleadd
    Menu, bar, Add, %menuname%, :%menuname%
}

Menu, bar, Add
Menu, bar, Add, Add Menu, handleaddmain
Menu, bar, Color, %MenuColor%

; ============End of Menus============

FileRead, Menutext, barmenu\bar.txt
StringSplit, NumWords, MenuText, `n
StringReplace, Menutext, Menutext, `r`n, , All
Menulength := StrLen(Menutext)
NewLength1 := MenuLength * 6
NewLength2 := Numwords0 * 8
NewLength := NewLength1 + NewLength2 + MenuWidth

Gui -Caption +Border +Owner
if OnTop = 1
{
    Menu, Tray, Check, Always on top
    Gui +AlwaysOnTop
}
Gui, Menu, bar
Gui,Show, w%NewLength% h0 Xcenter Y0 NoActivate

return


; ===============Menu functions===================

; ======Insert functions========

handleinsert:
IniRead, Output, barmenu\funcs.ini, commands, %A_ThisMenuItem%
if GetKeyState("Shift")
{
    SplitPath, Output,,DirVar
    Run %DirVar%
    return
}
if GetKeyState("Control")
{
    MsgBox, 36, Delete Item, Do you really want to delete %A_ThisMenuItem%?
    IfMsgBox No
    return

    Loop, Read, barmenu\%A_ThisMenu%.txt
    {
        if A_ThisMenuItem != %A_LoopReadLine%
        FileAppend, %A_LoopReadLine%`n, barmenu\%A_ThisMenu%_temp.txt
    }
    FileDelete, barmenu\%A_ThisMenu%.txt
    FileMove, barmenu\%A_ThisMenu%_temp.txt, barmenu\%A_ThisMenu%.txt
    IniDelete, barmenu\funcs.ini, commands, %A_ThisMenuItem%
    Reload
    Return
}
if GetKeyState("PgUp")
{
    if A_ThisMenuItemPos = 1
        return
    NLoop = 1
    NewPos := A_ThisMenuItemPos - 1
    Loop, Read, barmenu\%A_ThisMenu%.txt
    {
        if Nloop = %NewPos%
            FileAppend, %A_ThisMenuItem%`n, barmenu\%A_ThisMenu%_temp.txt
        if A_ThisMenuItem != %A_LoopReadLine%
            FileAppend, %A_LoopReadLine%`n, barmenu\%A_ThisMenu%_temp.txt
        Nloop := ++Nloop
    }
    FileDelete, barmenu\%A_ThisMenu%.txt
    FileMove, barmenu\%A_ThisMenu%_temp.txt, barmenu\%A_ThisMenu%.txt
    reload
    return
}
if GetKeyState("PgDn")
{
    TotalLoop = 0
    Loop, Read, barmenu\%A_ThisMenu%.txt
    {
        TotalLoop := ++TotalLoop
    }
    NLoop = 1
    NewPos := A_ThisMenuItemPos + 1
    if NewPos > %TotalLoop%
        return
    Loop, Read, barmenu\%A_ThisMenu%.txt
    {
        if A_ThisMenuItem != %A_LoopReadLine%
            FileAppend, %A_LoopReadLine%`n, barmenu\%A_ThisMenu%_temp.txt
        if Nloop = %NewPos%
            FileAppend, %A_ThisMenuItem%`n, barmenu\%A_ThisMenu%_temp.txt
        Nloop := ++Nloop
    }
    FileDelete, barmenu\%A_ThisMenu%.txt
    FileMove, barmenu\%A_ThisMenu%_temp.txt, barmenu\%A_ThisMenu%.txt
    reload
    return
}
Run %Output%
return

; =============Other commands============

handleadd:

if GetKeyState("Control")
{
    MsgBox, 36, Delete Menu, Do you really want to delete the menu "%A_ThisMenu%"?
    IfMsgBox No
    return

    Loop, Read, barmenu\bar.txt
    {
        if A_ThisMenu != %A_LoopReadLine%
        FileAppend, %A_LoopReadLine%`n, barmenu\bar_temp.txt
    }
    FileDelete, barmenu\bar.txt
    FileMove, barmenu\bar_temp.txt, barmenu\bar.txt
    Loop, Read, barmenu\%A_ThisMenu%.txt
    {
        IniDelete, barmenu\funcs.ini, commands, %A_LoopReadLine%
    }
    FileDelete, barmenu\%A_ThisMenu%.txt
    Reload
    return
}

    Gui, 2:Add, Text,, Program/shortcut name:
    Gui, 2:Add, Text,y+20, Program/shorcut path:
    Gui, 2:Add, Edit,x+40 w300 vnewmenuname ym
    Gui, 2:Add, Edit,y+10 w300 vnewcommandname, %NewItem%
   NewItem =
    Gui, 2:Add, Button,x+10,Browse
    Gui, 2:Add, Button,x230 y+20 default, OK
    Gui, 2:Add, Button,x+10,Cancel
    Gui, 2:Show,, Add new menu item

return

2ButtonBrowse:
FileSelectFile, foundcommandname, 35,, Select program/shortcut
GuiControl,2:, newcommandname, %foundcommandname%
return

2ButtonOK:
    Gui, 2:Submit
    Gui, 2:Destroy
    IniRead, Output, barmenu\funcs.ini, commands, %newmenuname%
    if Output != ERROR
    {
        MsgBox, This command already exists!
        return
    }
    if ErrorLevel
    {
        MsgBox, There was an error!
        Return
    }
    if newmenuname =
    {
        MsgBox, The Program/shortcut name was empty!
        Return
    }
    if newcommandname =
    {
        MsgBox, The Program/Shortcut was empty!
        Return
   }
   If (AddToMenu)
      FileAppend, %newmenuname%`n, barmenu\%AddToMenu%.txt
   Else
      FileAppend, %newmenuname%`n, barmenu\%A_ThisMenu%.txt
    IniWrite, %newcommandname%, barmenu\funcs.ini, commands, %newmenuname%
    Reload
return

2ButtonCancel:
2GuiClose:
Gui, 2:Destroy
return

handleaddmain:
InputBox, newmenuname, Add new menu, Enter the menu name:
if ErrorLevel
    Return
if newmenuname =
    Return
Loop, Read, barmenu\bar.txt
{
    mainmenuname = %A_LoopReadLine%
    if newmenuname = %mainmenuname%
    {
        Msgbox, Menu already exists!
        return
    }
    Loop, Read, barmenu\%A_LoopReadLine%.txt
    {
        menuname = %A_LoopReadLine%
        if newmenuname = %menuname%
        {
            Msgbox, Menu already exists!
            return
        }   
    }
}

FileAppend, %newmenuname%`n, barmenu\%A_ThisMenu%.txt
reload
return

OnTopChange:
If OnTop = 0
{
    OnTop = 1
    Menu, Tray, Check, Always on top
    Gui, +AlwaysOnTop
}
Else
{
    OnTop = 0
    Menu, Tray, UnCheck, Always on top
    Gui, -AlwaysOnTop
}
return

MoveIt:
If (Move)
{
   Move =
   Gui -Caption
   Gui, Show, h0
} Else {
   Move = 1
   Gui +Caption
   Gui, Show, h1
}
Return

ExHandleAd:
ClipBak := ClipboardAll
Clipboard =
Send ^c
ClipWait,2
If (ErrorLevel)
   Return
NewItem := Clipboard
Clipboard := ClipBak

Add2:
   Loop, Read, barmenu\bar.txt
   {
      MenuSelect = %MenuSelect%%A_LoopReadLine%|
   }
   Gui, 2:Add, Text,, Append to Menu:
   Gui, 2:Add, Text,y+20, Program/shortcut name:
    Gui, 2:Add, Text,y+20, Program/shorcut path:
   Gui, 2:Add, DropDownList, x+40 w300 vAddToMenu ym, %MenuSelect%
    Gui, 2:Add, Edit,y+10 w300 vnewmenuname
    Gui, 2:Add, Edit,y+10 w300 vnewcommandname, %NewItem%
   NewItem =
    Gui, 2:Add, Button,x+10,Browse
    Gui, 2:Add, Button,x230 y+20 default, OK
    Gui, 2:Add, Button,x+10,Cancel
    Gui, 2:Show,, Add new menu item
Return

GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
    NewItem := A_LoopField
    Break
}
GoSub, Add2
Return
