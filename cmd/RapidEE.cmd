@ECHO OFF

SETLOCAL

"%~dp0\StartApp.cmd" /n "%~n0" /t "Rapid Environment Editor" /e "RapidEE.exe" /f "RapidEE" /d "Edit the Environment Settings" /us %*
