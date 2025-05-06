@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET ARGS=
SET LINE=
SET COL=

:PARSEOPTS
IF /I "%~1" == "/L" SET LINE=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-L" SET LINE=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/C" SET COL=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-C" SET COL=%~2&&SHIFT && SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  SET ARGS=%ARGS% "%~1"
  SHIFT
  GOTO :PARSEOPTS
)

IF NOT "%LINE%%COL%" == "" (
    SET ARGS=%ARGS% -n%LINE%,%COL%
)
ECHO.%ARGS%

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "TSE UI Editor" /e "g32.exe" /f "TSE" /d "Edit a file in TSE UI Editor" /od "[filename] { [options] }" /oa "-l nn   Line to focus the cursor on" /oa "-c nn   Column to focus the cursor on" /rac 1 /nqa %ARGS%
