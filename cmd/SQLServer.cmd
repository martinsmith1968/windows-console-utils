@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET COMMAND=START
SET INSTANCENAME=MSSQLSERVER
SET POS=0
SET DEBUG=N

:PARSE
IF /I "%~1"=="-x" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1"=="/x" SET DEBUG=Y&&SHIFT&&GOTO :PARSEIF /I "%~1"=="-i" SET INSTANCENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1"=="/i" SET INSTANCENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1"=="-i" SET INSTANCENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1"=="-c" SET COMMAND=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1"=="/c" SET COMMAND=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

IF "%~1"=="" GOTO :VALIDATE

:POSITIONAL
SET /A POS+=1
IF %POS% == 1 (
    SET COMMAND=%~1
    SHIFT
    GOTO :PARSE
)

CALL :USAGE
CALL :ERROR "Unknown parameter : %~1"
GOTO :EOF


:VALIDATE
NET SESSION >NUL 2>&1
IF NOT %ERRORLEVEL% == 0 (
    ECHO.Warning: Needs ADMIN mode - current permissions insufficient
    @IF "%DEBUG%"=="Y" @ECHO ON
    RUNAS /noprofile /user:%USERNAME% /savecred "%SCRIPTFULLFILENAME% %*"
    @IF "%DEBUG%"=="Y" @ECHO OFF
    GOTO :EOF
)


:GO
ECHO.%COMMAND% : %INSTANCENAME%...

@IF "%DEBUG%"=="Y" @ECHO ON
NET %COMMAND% "SQL Server (%INSTANCENAME%)"
@IF "%DEBUG%"=="Y" @ECHO OFF

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Control SQL Server service
ECHO.
ECHO.%SCRIPTNAME% [command] [options]
ECHO.
ECHO.Commands:
ECHO.  start - Start the Instance (Default: %INSTANCENAME%)
ECHO.  stop  - Stop the Instance (Default: %INSTANCENAME%)
ECHO.
ECHO.Options:
ECHO.  /i [name] - Specify the Instance to use
ECHO.  /x        - Debug mode
