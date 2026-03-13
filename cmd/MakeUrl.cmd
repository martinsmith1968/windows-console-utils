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

SET TARGETURL=
SET FILENAME=
SET FOLDER=

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

IF /I "%~1" == "/F" SET FOLDER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-F" SET FOLDER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/N" SET FILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-N" SET FILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET TARGETURL=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
IF "%TARGETURL%" == "" SET USAGE=Y
IF "%FILENAME%" == "" (
   IF NOT "%FOLDER%" == "" (
      CALL :ERROR "Cannot specify output Folder without Filename."
      SET USAGE=Y
   )
)

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

:GO
IF "%DEBUG%" == "Y" (
    ECHO.TARGETURL = %TARGETURL%
    ECHO.FOLDER    = %FOLDER%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

SET CMDOUTPUT=%FILENAME%
IF NOT "%FOLDER%" == "" SET CMDOUTPUT=%FOLDER%
IF NOT "%CMDOUTPUT%" == "" SET CMDOUTPUT=%CMDOUTPUT%\
SET CMDOUTPUT=%CMDOUTPUT%%FILENAME%

IF NOT "%CMDOUTPUT%" == "" (
    SET CMDOUTPUT=^>^>"%CMDOUTPUT%"
)

IF "%DEBUG%" == "Y" (
    ECHO.CMDOUTPUT = %CMDOUTPUT%
)


@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%ECHO.[InternetShortcut]%CMDOUTPUT%
%COMMANDPREFIX%ECHO.URL=%TARGETURL%%CMDOUTPUT%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Generate a URL file to launch to a target URL  
ECHO.
ECHO.Usage: %SCRIPTNAME% [URL] { [options] }
ECHO.
ECHO.Options:
ECHO. /n  - Output filename (Default: none - prints to console)
ECHO. /f  - Output folder

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
