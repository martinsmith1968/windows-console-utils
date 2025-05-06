@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET ARGPOS=0
SET DEBUG=N
SET DRYRUN=N
SET USAGE=N

SET COMMANDPREFIX=

SET MYOPT1=N
SET MYOPT2=N
SET MYOPT3=N
SET WILDCARD=
SET COMMAND=

REM **********************************************************************
REM ** Guides
REM ** - Variable Substring : https://ss64.com/nt/syntax-substring.html
REM **********************************************************************


:PARSE
IF "%~1" == "" GOTO :VALIDATE

IF /I "%~1" == "/?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/1" SET MYOPT1=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/2" SET MYOPT2=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/3" SET MYOPT3=Y&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET WILDCARD=%~1&&SHIFT&&GOTO :PARSE
IF %ARGPOS% EQU 2 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
IF "%WILDCARD%" == "" SET USAGE=Y
IF "%COMMAND%" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

:GO
IF "%DEBUG%" == "Y" (
    ECHO.WILDCARD = %WILDCARD%
    ECHO.COMMAND  = %COMMAND%
    ECHO.MYOPT1   = %MYOPT1%
    ECHO.MYOPT2   = %MYOPT2%
    ECHO.MYOPT3   = %MYOPT3%
    ECHO.DEBUG    = %DEBUG%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%ECHO. %COMMAND% %WILDCARD% -o1 %MYOPT1% -o2 %MYOPT2% -o3 %MYOPT3%
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
