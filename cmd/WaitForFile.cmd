@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTFILE=%~nx0
SET SCRIPTNAME=%~n0

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

SET FILENAME=%~1
SET MODE=%~2
SET AUTOMANAGE=%~3

IF "%MODE%" == "" SET MODE=EXIST

:START
GOTO :%MODE%
GOTO :EOF


:EXIST
ECHO.Waiting for: %FILENAME% to exist...
:EXISTRETRY
IF NOT EXIST "%FILENAME%" GOTO :EXISTRETRY

IF /I "%AUTOMANAGE%" == "Y" (
    ECHO.Removing: %FILENAME%
    DEL /F /Q "%FILENAME%" >NUL
)

GOTO :EOF


:NOTEXIST
ECHO.Waiting for: %FILENAME% to disappear...
:NOTEXISTRETRY
IF EXIST "%FILENAME%" GOTO :NOTEXISTRETRY

IF /I "%AUTOMANAGE%" == "Y" (
    ECHO.Creating: %FILENAME%
    TOUCH "%FILENAME%"
)

GOTO :EOF


GOTO :EOF

:USAGE
ECHO.%SCRIPTNAME% - Suspend a batch file by waiting for a file to exist or not
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [ filename ] { [ EXIST / NOTEXIST ] [ Y / N - Auto manage file ] }
