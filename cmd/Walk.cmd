@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N

:PARSEOPTIONS
IF /I "%~1" == "/X" (
    SET DEBUG=Y
    SHIFT
    GOTO :PARSEOPTIONS
)

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

FOR %%F IN ("%path:;=";"%") DO (
    PUSHD "%%~F"
    
    IF "%DEBUG%" == "Y" (
        ECHO.%1
    ) ELSE (
        %~1
    )
    
    POPD
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Walk every entry in PATH and execute a command
ECHO.
ECHO.Usage: %SCRIPTNAME% { [options] } [command]
ECHO.
ECHO.Options: /X - Do not execute command (debug)

GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF
