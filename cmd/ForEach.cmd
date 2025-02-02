@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET DEBUG=N
SET USAGE=N
SET FOROPTS=
SET EXECCOMMAND=Y
SET ECHOCOMMAND=Y
SET ECHOCD=Y
SET APPEND=N
SET SWITCH=N

:PARSEOPTS
IF /I "%~1" == "/?" (
    SET USAGE=Y
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/X" (
    SET DEBUG=Y
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/D" (
    SET FOROPTS=/D
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/NE" (
    SET ECHOCOMMAND=N
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/NC" (
    SET ECHOCD=N
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/A" (
    SET APPEND=Y
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/A-" (
    SET APPEND=N
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/NX" (
    SET EXECCOMMAND=N
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/SW" (
    SET SWITCH=Y
    SET FOROPTS=/D
    SHIFT
    GOTO :PARSEOPTS
)

IF "%~2" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

SET WILDCARD=%~1
SET COMMANDSPEC=%~2

IF "%DEBUG%" == "Y" (
    ECHO.COMMAND     = %COMMAND%
    ECHO.FOROPTS     = %FOROPTS%
    ECHO.EXECCOMMAND = %EXECCOMMAND%
    ECHO.ECHOCOMMAND = %ECHOCOMMAND%
    ECHO.APPEND      = %APPEND%
    ECHO.SWITCH      = %SWITCH%
)

FOR %FOROPTS% %%F IN (%WILDCARD%) DO CALL :EXECTARGET "%%~F"

GOTO :EOF


:EXECTARGET
SET TARGET=%~1
SET COMMAND=%COMMANDSPEC%
IF "%APPEND%" == "Y" SET COMMAND=%COMMANDSPEC% ##TARGET##
SET COMMAND=%COMMAND:##TARGET##=!TARGET!%

IF "%SWITCH%" == "Y" (
  IF "%ECHOCD%" == "Y" ECHO.CD: %TARGET%
  PUSHD "%TARGET%"
)  

IF "%ECHOCOMMAND%" == "Y" (
    ECHO.%COMMAND%
)
    
IF "%EXECCOMMAND%" == "Y" (
    %COMMAND%
)
    
IF "%SWITCH%" == "Y" POPD

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Execute a command over a series of files
ECHO.
ECHO.Usage: %~n0 { [options] } [wildcard] [command]
ECHO.
ECHO.[command] can include the text ##TARGET## which will get replaced
ECHO.          with the matched file/folder
ECHO.
ECHO.Options: /D  - Wildcard matches against directories not files
ECHO.         /A  - Append matched file/folder name to command
ECHO.         /NE - Suppress echo of command to be executed
ECHO.         /NC - Suppress echo of CD directory switch
ECHO.         /NX - Suppress execution of command (negates /NE)
ECHO.         /SW - Switch to found directory (invokes /D)

GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF
