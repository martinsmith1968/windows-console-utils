@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

IF "%~1" == "" (
    ECHO.Usage: %SCRIPTNAME% [JS-Script-Name] { [parameters] }
    GOTO :EOF
)

SET JSSCRIPTNAME=%~1

SHIFT

NODE "%SCRIPTPATH%\..\JavaScript\%JSSCRIPTNAME%.js" %1 %2 %3 %4 %5 %6 %7 %8
