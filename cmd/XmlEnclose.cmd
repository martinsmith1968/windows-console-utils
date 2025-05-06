@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
    CALL :_USAGE
    GOTO :EOF
)

IF NOT EXIST "%~1" (
    CALL :_HEADER
    CALL :_ERROR "File not found - %~1"
    GOTO :EOF
)

SET DATATAG=%~2

SET TEMPFILE=%TEMP%\%SCRIPTNAME%-%~n1.tmp

ECHO.^<?xml version="1.0" encoding="utf-8"?^> > %TEMPFILE%

IF NOT "%DATATAG%" == "" (
    ECHO.^<%DATATAG%^> >> "%TEMPFILE%"
)

TYPE "%~1" >> "%TEMPFILE%"

IF NOT "%DATATAG%" == "" (
    ECHO.^</%DATATAG%^> >> "%TEMPFILE%"
)

TYPE "%TEMPFILE%"

IF EXIST "%TEMPFILE%" (
    DEL /Q "%TEMPFILE%"
)

GOTO :EOF


REM ********************************************************************************
:_HEADER
ECHO.%SCRIPTNAME% - Enclose a file inside XML tags
ECHO.

GOTO :EOF


:_ERROR
ECHO.ERROR: %~1

GOTO :EOF


REM ********************************************************************************
:_USAGE
CALL :_HEADER
ECHO.Usage:
ECHO.%SCRIPTNAME% file-name [ {enclosing-tag-name} ]
ECHO.

GOTO :EOF
