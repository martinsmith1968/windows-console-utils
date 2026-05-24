@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

CALL :CREATE %*

GOTO :EOF


:USAGE
ECHO %SCRIPTNAME% - Create a startup shortcut for a target executable
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [target] { [arguments] }
GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:CREATE
SET FILENAME=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\%~n1.lnk

SET ACTION=C
IF EXIST "%FILENAME%" (
    SET ACTION=E
)

SHORTCUT /F:"%FILENAME%" /A:%ACTION% /T:"%~dpnx1" /P:"%~2"

GOTO :EOF
