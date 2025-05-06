@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0

"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "P4 Merge" /e "p4merge.exe" /f "Perforce" /d "Compare 2 files/folders" /od "[filename1] [filename2]" /us /rac 2 /nqa %*
