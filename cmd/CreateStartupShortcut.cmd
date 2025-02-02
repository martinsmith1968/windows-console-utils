@ECHO OFF

SETLOCAL

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

CALL :CREATE %*

GOTO :EOF


:USAGE
ECHO %~n0 - Create a startup shortcut for a target executable
ECHO.
ECHO.Usage:
ECHO.%~n0 [target] { [arguments] }
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
