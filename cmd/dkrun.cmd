@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM Needs work

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET INDEX=0
SET HELP=N
SET DEBUG=N
SET DRYRUN=N
SET EXPOSE=
SET INTERACTIVE=Y
SET VOLUME=
SET IMAGENAME=ubuntu:22.04
SET CONTAINERNAME=%CURRENTDIRNAME%

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/I" SET INTERACTIVE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-I" SET INTERACTIVE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/I-" SET INTERACTIVE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-I-" SET INTERACTIVE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/P" SET EXPOSE=%~2:%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-P" SET EXPOSE=%~2:%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/M" SET IMAGE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-M" SET IMAGE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V" SET VOLUME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VOLUME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE


SET /A INDEX+=1

CALL :USAGE
CALL :ERROR "Unexpected argument at pos: %INDEX% - %~1"
GOTO :EOF


:VALIDATE
IF "%HELP%" == "Y" CALL :USAGE&&GOTO :EOF


:GO
SET PREFIX=
IF "%DRYRUN%" == "Y" SET PREFIX=ECHO.

SET ARGS=--name "%CONTAINERNAME%"

IF "%INTERACTIVE%" == "Y" SET ARGS=%ARGS% -it
IF NOT "%EXPOSE%" == "" SET ARGS=%ARGS% --expose %EXPOSE%

%PREFIX%docker run %ARGS% %IMAGENAME%

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Run a docker image
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [options]
ECHO.
ECHO.Options:
ECHO. /I            Run interactively (Default: %INTERACTIVE%)
ECHO. /I-           Disable interactive
ECHO. /M [name]     Run the specified image (Default: %IMAGENAME%)
ECHO. /C [name]     Use the specified container name (Default: %CONTAINERNAME%)
ECHO. /P [port]     Expose the specified port (as port:port)
ECHO. /V [map]     	Map the specified volume (format: local:remote)
ECHO.

GOTO :EOF
