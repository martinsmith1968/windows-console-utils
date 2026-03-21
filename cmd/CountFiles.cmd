@ECHO OFF

REM **********************************************************************
REM ** NOTE:
REM ** - VERBOSE doesn't work as exits before can check value
REM **********************************************************************

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET ARGPOS=0
SET HELP=N
SET DEBUG=N

SET DIR=%CD%
SET WILDCARD=*.*
SET VERBOSE=N
SET ADDITIONAL=REM.

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/V" SET VERBOSE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-V" SET VERBOSE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/W" SET WILDCARD=%~2&&SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-W" SET WILDCARD=%~2&&SHIFT && SHIFT && GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET DIR=%~1&&SHIFT && GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position %ARGPOS%: %~1%"
GOTO :EOF


:VALIDATE
IF "%HELP%" == "Y" (
    CALL :USAGE
    GOTO :EOF
)


:START
IF "%DEBUG%%" == "Y" (
    ECHO.DIR      = %DIR%
    ECHO.WILDCARD = %WILDCARD%
    ECHO.VERBOSE  = %VERBOSE%
)

SET FILECOUNT=0

IF NOT EXIST "%DIR%\%WILDCARD%" GOTO :EOF

IF "%VERBOSE%" == "Y" (
    SET ADDITIONAL=ECHO.%DIR% [%WILDCARD%] :
)

FOR /F %%C IN ('dir /a-d /b "%DIR%\%WILDCARD%" ^| wc -l') DO ENDLOCAL && SET FILECOUNT=%%C&&%ADDITIONAL% %%C files


GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Count the number of files in a directory, matching a wildcard
ECHO.
ECHO.Usage: %SCRIPTNAME% [directory:%DIR%] [wildcard:%WILDCARD%] { [options] }
ECHO.
ECHO.Options:
ECHO. /?  - Show Help page
ECHO. /X  - Activate Debug mode (Default: %DEBUG%)

GOTO :EOF


:ERROR
SET ERRORTEXT=
:ERRORLOOP
IF NOT "%~1" == "" (
    SET ERRORTEXT=%ERRORTEXT% %~1
    SHIFT
    GOTO :ERRORLOOP
)
ECHO.ERROR:%ERRORTEXT%
GOTO :EOF
