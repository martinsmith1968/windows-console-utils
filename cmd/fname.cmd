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

SET FILENAME=

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

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET FILENAME=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
IF "%FILENAME%" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

:GO
IF "%DEBUG%" == "Y" (
    ECHO.FILENAME  = %FILENAME%
    ECHO.DEBUG     = %DEBUG%
    ECHO.DRYRUN    = %DRYRUN%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

IF NOT EXIST "%FILENAME%" (
    ECHO.ERROR: %FILENAME% does not exist
)

CALL :SHOWFILENAME "%FILENAME%"

GOTO :EOF


:SHOWFILENAME
IF "%~1" == "" GOTO :EOF

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%ECHO.%~dpnx1%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Show the full filename of a file
ECHO.
ECHO.Usage: %SCRIPTNAME% [filename] { [options] }
ECHO.

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
