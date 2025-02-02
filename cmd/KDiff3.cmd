@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0

"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "KDiff3" /e "kdiff3.exe" /f "KDiff3" /d "Compare 2 files/folders" /od "[filename1] [filename2]" /us /rac 2 /nqa %*
