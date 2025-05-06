@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

IF "%~1" == "" (
    ECHO.Usage: %SCRIPTNAME% [Powershell-Script-Name] { [parameters] }
    GOTO :EOF
)

SET FILENAME=%~1

SHIFT

pwsh "%SCRIPTPATH%\..\Powershell\%FILENAME%.ps1" %1 %2 %3 %4 %5 %6 %7 %8
