@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM **********************************************************************
REM See also : https://github.com/bradygaster/squad
REM **********************************************************************

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET ARGPOS=0
SET DEBUG=Y
SET DRYRUN=N
SET USAGE=N

SET COMMANDPREFIX=

SET AGENT=squad
SET YOLO=Y
SET RESUME=N


:PARSE
IF "%~1" == "" GOTO :VALIDATE

IF /I "%~1" == "/?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/Y"  SET YOLO=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y"  SET YOLO=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y-" SET YOLO=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y-" SET YOLO=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/R"  SET RESUME=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-R"  SET RESUME=Y&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
REM IF %ARGPOS% EQU 1 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

:GO
IF "%DEBUG%" == "Y" (
    ECHO.AGENT  = %AGENT%
    ECHO.YOLO   = %YOLO%
    ECHO.RESUME = %RESUME%
)

SET ARGS=
IF NOT "%AGENT%" == "" SET ARGS=%ARGS% --agent %AGENT%
IF "%YOLO%" == "Y"     SET ARGS=%ARGS% --yolo
IF "%RESUME%" == "Y"   SET ARGS=%ARGS% --resume

IF "%DEBUG%" == "Y" (
  ECHO.ARGS   = %ARGS%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%copilot %ARGS%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Sample Command with parsing
ECHO.
ECHO.Usage: %SCRIPTNAME% [wildcard] [command] { [options] }
ECHO.
ECHO.Options:
ECHO. /1  - Some Option 1
ECHO. /2  - Some Option 2
ECHO. /3  - Some Option 3

GOTO :EOF


:ERROR
SET ERROTEXT=
:ERRORLOOP
IF NOT "%~1" == "" (
  SET ERRORTEXT=%ERRORTEXT% %~1
  SHIFT
  GOTO :ERRORLOOP
)
ECHO.ERROR:%ERRORTEXT%
GOTO :EOF
