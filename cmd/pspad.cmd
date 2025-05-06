@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET ARGS=

:PARSEOPTS
IF /I "%~1" == "/L" SET ARGS=%ARGS% -p "-%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-L" SET ARGS=%ARGS% -p "-%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  SET ARGS=%ARGS% "%~1"
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "PSPad Editor" /e "PSPad.exe" /f "PSPad Editor" /d "Edit a file in PSPad" /od "[filename] { [options] }" /oa "-l nn   Line to focus the cursor on" /us /rac 1 /nqa %ARGS%
