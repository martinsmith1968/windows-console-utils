REM @ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.bacpac

SET RESTORECMD=%SCRIPTPATH%\SQLRestoreDb.cmd

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

:LOOP
IF "%~1" == "" GOTO :EOF

FOR %%F IN (%~1) DO (
    CALL "%RESTORECMD%" "%%~F"
)

SHIFT
GOTO :LOOP


:USAGE
ECHO.%SCRIPTNAME% - Restore a set of Dbs from %BACKUPEXTENSION% files
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [filename-or-wildcard] { [filename-or-wildcard] ... }

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
