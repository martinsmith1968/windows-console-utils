@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0

"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "WinMerge" /e "winmergeu.exe" /f "WinMerge" /d "Compare 2 files/folders" /od "[filename1] [filename2]" /us /rac 0 /nqa %*
