@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "7-Zip" /e "7zfm.exe" /f "7-Zip" /d "Open an archive in 7-Zip" /od "[filename]" /us /rac 1 /nqa %*
