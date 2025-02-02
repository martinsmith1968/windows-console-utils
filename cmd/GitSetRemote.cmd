@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET DEBUG=N
SET USAGE=N
SET REMOTENAME=origin
SET FOREACHOPTS=
SET REMOTEURL=

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
IF /I "%~1" == "/N" (
    SET ORIGIN=%~2
    SHIFT
    GOTO :PARSEOPTS
)
IF /I "%~1" == "/S" (
    SET FOREACHOPTS=/D
    SHIFT
    GOTO :PARSEOPTS
)

IF "%~1" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

SET REMOTEURL=%~1

IF "%DEBUG%" == "Y" (
    ECHO.REMOTENAME  = %REMOTENAME%
    ECHO.REMOTEURL   = %REMOTEURL%
    ECHO.FOREACHOPTS = %FOREACHOPTS%
    ECHO.DEBUG       = %DEBUG%
)

REM Execute
CALL ForEach.cmd %FOREACHOPTS% 

GOTO :EOF




:SETREMOTE
SET REPO=%~1

ECHO.Repo: %REPO%

PUSHD "%REPO%"

SET REPO_ORIGIN=

IF NOT "%ORIGIN%" == "" SET REPO_ORIGIN=%ORIGIN%/%REPO%

IF NOT "%ORIGIN%" == "" (
  ECHO.Before:
  git remote -v

  @ECHO ON
  git remote set-url origin "%ORIGIN%"
  @ECHO OFF

  ECHO.After:
  git remote -v
)

POPD

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Set GIT remote for a collection of repositories
ECHO.
ECHO.Usage: %~n0 { [options] } [remote-url]
ECHO.
ECHO.Options: /N  - Remote name (Default: %ORIGIN%)
ECHO.         /S  - Append matched file/folder name to command
ECHO.
ECHO.Example:
ECHO.%~n0 /S "https://martinsmith1968:pat@bitbucket.org/martinsmith1968"

GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF
