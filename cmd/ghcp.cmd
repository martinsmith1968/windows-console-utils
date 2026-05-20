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
SET VERBOSE=N

SET COMMANDPREFIX=

SET AGENT=squad
SET YOLO=Y
SET RESUME=N
SET CLEARSCREENAFTER=Y
SET AUTOTITLEMODE=CD
SET TITLE=


:PARSE
IF "%~1" == "" GOTO :VALIDATE

IF /I "%~1" == "/?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/Y"  SET YOLO=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y"  SET YOLO=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y-" SET YOLO=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y-" SET YOLO=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/R"  SET RESUME=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-R"  SET RESUME=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/C"  SET CLEARSCREENAFTER=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-C"  SET CLEARSCREENAFTER=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/C-" SET CLEARSCREENAFTER=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-C-" SET CLEARSCREENAFTER=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/AT" SET AUTOTITLEMODE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-AT" SET AUTOTITLEMODE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/T"  SET TITLE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-T"  SET TITLE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

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

IF "%TITLE%" == "" (
  IF NOT "%AUTOTITLEMODE%" == "" (
    IF "%AUTOTITLEMODE%" == "CD" (
      CALL :SETTITLEBYPATHNAME "%CD%"
    ) ELSE (
      CALL TITL.CMD %AUTOTITLEMODE%
      SET TITLE=!CONSOLE_TITLE!
    )
  )
)

SET ARGS=
IF NOT "%AGENT%" == "" SET ARGS=%ARGS% --agent %AGENT%
IF "%YOLO%" == "Y"     SET ARGS=%ARGS% --yolo
IF "%RESUME%" == "Y"   SET ARGS=%ARGS% --resume
IF NOT "%TITLE%" == "" SET ARGS=%ARGS% --name "%TITLE%"

IF "%DEBUG%" == "Y" (
  ECHO.ARGS   = %ARGS%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%copilot %ARGS%
@IF "%DEBUG%" == "Y" @ECHO OFF

IF "%CLEARSCREENAFTER%" == "Y" CLS

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Lauch GitHub Copilot CLI with some options
ECHO.
ECHO.Usage: %SCRIPTNAME% { [options] }
ECHO.
ECHO.Options:
ECHO. /Y[-]       - Activate / Deactivate YoLo mode (Default: %YOLO%)
ECHO. /C[-]       - Activate / Deactivate Clear Screen After mode (Default: %CLEARSCREENAFTER%)
ECHO. /R          - Resume a previous session if one exists
ECHO. /T [text]   - Specify Console title to use (Default: %DISTRO% %DISTROVERSION% - %INSTANCENAME%)
ECHO. /AT [mode]  - Auto-generate Console title based on Distro, DistroVersion and InstanceName
ECHO.
ECHO. /V  - Activate Verbose mode
ECHO. /Z  - Dry Run
ECHO. /X  - Activate Debug Mode
ECHO. /?  - Display this help message

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


:SETTITLEBYPATHNAME
SET TITLE=%~nx1
GOTO :EOF
