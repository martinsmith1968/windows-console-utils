@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET ARGPOS=0
SET DEBUG=N
SET USAGE=N

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

IF /I "%~1" == "/1" SET MYOPT1=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/2" SET MYOPT2=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/3" SET MYOPT3=Y&&SHIFT&&GOTO :PARSE

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
    ECHO.FILENAME = %FILENAME%
    ECHO.DEBUG    = %DEBUG%
)

ECHO.Examining %FILENAME% for duplicate labels...
@IF "%DEBUG%" == "Y" @ECHO ON
CAT "%FILENAME%" | grep -E "^:[A-Za-z]+$" | SORT | uniq -d
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Sample Command with parsing
ECHO.
ECHO.Usage: %SCRIPTNAME% [filename] { [options] }
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
