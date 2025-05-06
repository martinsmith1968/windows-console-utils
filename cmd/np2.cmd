@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET ARGS=

:PARSEOPTS
IF /I "%~1" == "/L" SET ARGS=%ARGS% -p "-n%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-L" SET ARGS=%ARGS% -p "-n%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/C" SET ARGS=%ARGS% -p "-c%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-C" SET ARGS=%ARGS% -p "-c%~2"&&SHIFT && SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  SET ARGS=%ARGS% "%~1"
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "Notepad2" /e "notepad2.exe" /f "win" /d "Edit a file in Notepad2" /od "[filename] { [options] }" /us /rac 1 /nqa %ARGS%
