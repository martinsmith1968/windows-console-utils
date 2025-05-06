@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTFILE=%~nx0
SET SCRIPTNAME=%~n0

:START
SET HOSTSFILE=%SystemRoot%\System32\Drivers\etc\hosts
SET MODE=%~1

IF "%MODE%"=="" SET MODE=VIEW

GOTO :%MODE% >NUL

CALL :USAGE "Invalid Mode - %MODE%"
GOTO :EOF


:EDIT
CALL NPP "%HOSTSFILE%"
GOTO :EOF


:VIEW
TYPE %HOSTSFILE%
GOTO :EOF

:COPY
ECHO.%HOSTSFILE%|CLIP
ECHO.Copied to clipboard : %HOSTSFILE%
GOTO :EOF

:USAGE
ECHO.%SCRIPTNAME% - Show / Edit the Hosts file
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [ mode ]
ECHO.
ECHO.Mode can be:
ECHO.  SHOW     (Default) List the hosts file
ECHO.  EDIT     Open the hosts file in Notepad++
IF NOT "%~1" == "" (
    ECHO.
    ECHO.Error: %~1
)
