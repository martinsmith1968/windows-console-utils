@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET ARGS=

:PARSEOPTS
IF NOT "%~1" == "" (
  SET ARGS=%ARGS% "%~1"
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "Beyond Compare" /e "BCompare.exe" /f "Beyond Compare 5" /d "Compare 2 Files / Folders" /od "[file target 1] [file target 2] { [options] }"  /us /rac 1 /nqa %ARGS%
