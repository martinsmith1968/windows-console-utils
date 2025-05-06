@ECHO OFF

SETLOCAL

"%~dp0\StartApp.cmd" /n "%~n0" /t "XnView NConvert" /e "nconvert.exe" /f "NConvert" /d "Edit/Convert an image file" /od "[filename] [options]" /hc "-help" /rac 1 %*
