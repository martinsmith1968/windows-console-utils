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
SET VERBOSE=Y

SET COMMANDPREFIX=

SET CONFIG_FILENAME=AppConfig.yaml
SET OUTPUT_FILENAME=AppConfig.json
SET ALLOW_JSON_COMMENTS=Y
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
IF /I "%~1" == "/V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V-" SET VERBOSE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V-" SET VERBOSE=N&&SHIFT&&GOTO :PARSE

REM IF /I "%~1" == "/1" SET MYOPT1=Y&&SHIFT&&GOTO :PARSE
REM IF /I "%~1" == "/2" SET MYOPT2=Y&&SHIFT&&GOTO :PARSE
REM IF /I "%~1" == "/3" SET MYOPT3=Y&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
REM IF %ARGPOS% EQU 1 SET WILDCARD=%~1&&SHIFT&&GOTO :PARSE
REM IF %ARGPOS% EQU 2 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE

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
    ECHO.DEBUG    = %DEBUG%
    ECHO.DRYRUN   = %DRYRUN%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

SET FILECOUNT=0

@IF "%DEBUG%" == "Y" @ECHO ON
FOR /F %%F IN ('dir /s /b "%CONFIG_FILENAME%"') DO (
    SET /A FILECOUNT+=1
    CALL :CONVERT_YAML "%%~F"
)
@IF "%DEBUG%" == "Y" @ECHO OFF

IF "%VERBOSE%" == "Y" (
    ECHO.Processed: %FILECOUNT% files
)

GOTO :EOF


:CONVERT_YAML
IF "%~1" == "" GOTO :EOF
IF NOT EXIST "%~1" GOTO :EOF

SET TARGET=%~dp1\%OUTPUT_FILENAME%
IF "%VERBOSE%" == "Y" ECHO.Converting: %~dpnx1

SET COMMANDSUFFIX=^>
IF "%ALLOW_JSON_COMMENTS%" == "Y" (
    ECHO.// Converted from %~1> "%TARGET%"
    ECHO.// By %SCRIPTFULLPATH% on %DATE% at %TIME% >> "%TARGET%"
    ECHO.//>> "%TARGET%"

    SET COMMANDSUFFIX=^>^>
)
IF NOT "%COMMANDPREFIX%" == "" SET COMMANDSUFFIX=

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%yq -p yaml -o json "%~dpnx1" %COMMANDSUFFIX% "%TARGET%"

%COMMANDPREFIX%FART -v -i "%TARGET%" "$DefaultShortcutTarget$" "shell:programsmenu"
%COMMANDPREFIX%FART -v -i "%TARGET%" "$DefaultShortcutFolder$" "utils"
@IF "%DEBUG%" == "Y" @ECHO OFF

IF NOT "%ALLOW_JSON_COMMENTS%" == "Y" (
    CAT "%TARGET%" | jq --arg when "%DATE% %TIME%" ".__generated = $when"
    REM TODO: Redirect to temp file then copy back
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Convert all %CONFIG_FILENAME% files to JSON
ECHO.
ECHO.Usage: %SCRIPTNAME% { [options] }
ECHO.
ECHO.Options:
ECHO. /?    - Show Usage
ECHO. /V[-] - Enable/Disable Verbouse output (Default: %VERBOSE%)
ECHO. /X    - Activate Debug mode (Default: %DEBUG%)
ECHO. /Z    - Activate DryRun mode (Default: %DRYRUN%)

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
