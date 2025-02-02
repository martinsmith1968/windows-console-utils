@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

IF "%~1" == "" (
    ECHO.Usage: %SCRIPTNAME% [Python-Script-Name] { [parameters] }
    GOTO :EOF
)

SET PYSCRIPTNAME=%~1

SHIFT

python "%SCRIPTPATH%\..\python\%PYSCRIPTNAME%.py" %1 %2 %3 %4 %5 %6 %7 %8
