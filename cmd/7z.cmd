@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET COMMAND=l
SET ARGS=

:PARSEOPTS
IF /I "%~1" == "/C" SET COMMAND=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-C" SET COMMAND=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  SET ARGS=%ARGS% "%~1"
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "7-Zip" /e "7z.exe" /f "7-Zip" /d "Open an archive in 7-Zip" /od "[filename]" /rac 1 /nqa %COMMAND% %ARGS%
