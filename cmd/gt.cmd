@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET I=0

SET /A I+=1
SET COMMAND[%I%].NAME=status
SET COMMAND[%I%].LABEL=STATUS
SET COMMAND[%I%].DESC=Show current status information

SET /A I+=1
SET COMMAND[%I%].NAME=branch
SET COMMAND[%I%].LABEL=BRANCH
SET COMMAND[%I%].DESC=Show current branch

SET /A I+=1
SET COMMAND[%I%].NAME=unstage
SET COMMAND[%I%].LABEL=UNSTAGE
SET COMMAND[%I%].DESC=Unstage a file already added

SET /A I+=1
SET COMMAND[%I%].NAME=reset
SET COMMAND[%I%].LABEL=RESET
SET COMMAND[%I%].DESC=Reset (Undo) changes to a file

SET /A I+=1
SET COMMAND[%I%].NAME=remstat
SET COMMAND[%I%].LABEL=REMOTEBRANCHSTATUS
SET COMMAND[%I%].DESC=Show Remote Branch Status

SET /A I+=1
SET COMMAND[%I%].NAME=config
SET COMMAND[%I%].LABEL=SHOWCONFIG
SET COMMAND[%I%].DESC=Show all Config (with scopes / files)

SET /A I+=1
SET COMMAND[%I%].NAME=test
SET COMMAND[%I%].LABEL=TEST
SET COMMAND[%I%].DESC=Testing

SET /A I+=1
SET COMMAND[%I%].NAME=clean
SET COMMAND[%I%].LABEL=CLEAN
SET COMMAND[%I%].DESC=Clean all untracked files

SET /A COUNT=%I%

REM *** Parse
IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

REM *** Match a command
SET FOUND=

CALL :LOCATECOMMANDEXACT "%~1"
IF NOT "%FOUND%" == "" (
    CALL :!LABEL! %*
    GOTO :EOF
)

CALL :LOCATECOMMANDBEST "%~1"
IF NOT "%FOUND%" == "" (
    CALL :!LABEL! %*
    GOTO :EOF
)

ECHO.
ECHO.Error: Command not found: %~1

IF %CANDIDATES% GTR 0 (
    ECHO.
    ECHO.Ambiguous Command:
    FOR /L %%F IN (1,1,%CANDIDATES%) DO (
        CALL :SETCOMMAND !CANDIDATE[%%F]!

        ECHO.!NAME! - !DESC!
    )
)

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF


:SETCOMMAND
SET "NAME=!COMMAND[%~1].NAME!"
SET "LABEL=!COMMAND[%~1].LABEL!"
SET "DESC=!COMMAND[%~1].DESC!"

GOTO :EOF


:LOCATECOMMANDEXACT
SET FOUND=

FOR /L %%F IN (1,1,%COUNT%) DO (
    CALL :SETCOMMAND %%F
    
    IF /I "%~1" == "!NAME!" (
        SET FOUND=%%F
        GOTO :EOF
    )
)

GOTO :EOF


:LOCATECOMMANDBEST
SET FOUND=

SET CANDIDATES=0

FOR /L %%F IN (1,1,%COUNT%) DO (
    CALL :SETCOMMAND %%F
    
    ECHO.!NAME!|FINDSTR "^%~1">NUL && SET /A CANDIDATES+=1 && SET "CANDIDATE[!CANDIDATES!]=%%F"
)

IF %CANDIDATES% EQU 0 (
    GOTO :EOF
)

IF %CANDIDATES% EQU 1 (
    SET FOUND=%CANDIDATE[1]%
    CALL :SETCOMMAND %CANDIDATE[1]%
    GOTO :EOF
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - GIT shortcuts
ECHO.
FOR /L %%F IN (1,1,%COUNT%) DO (
    CALL :SETCOMMAND %%F

    ECHO.!NAME! - !DESC!
)

GOTO :EOF


:STATUS
GIT status

GOTO :EOF


:BRANCH
GIT rev-parse --abbrev-ref HEAD

GOTO :EOF


:UNSTAGE
IF "%~2" == "" (
  CALL :ERROR Invalid filename to unstage
  GOTO :EOF
)

GIT reset HEAD "%~2"

GOTO :EOF


:RESET
IF "%~2" == "" (
  CALL :ERROR Invalid filename to reset
  GOTO :EOF
)

GIT checkout -- "%~2"

GOTO :EOF


:REMOTEBRANCHSTATUS
CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.RemoteBranchStatus.tmp"
SET TEMPFILENAME=%UNIQUETEMPFILENAME%

git branch -r | grep -v HEAD > "%TEMPFILENAME%"

FOR /F %%F IN (%TEMPFILENAME%) DO CALL :SHOWSTATUS "%%~F"

DEL /Q "%TEMPFILENAME%" >NUL

GOTO :EOF


:SHOWSTATUS
git show --format="%%ci %%cr %%cn %%d" "%~1" | head -n 1

GOTO :EOF


:SHOWCONFIG
SET PARAM=--show-scope
IF /I "%~2" == "FILE"  SET PARAM=--show-origin
IF /I "%~2" == "FILES" SET PARAM=--show-origin

git config --list %PARAM%

GOTO :EOF


:TEST
ECHO.1 = %~1
ECHO.2 = %~2
ECHO.3 = %~3
ECHO.4 = %~4

GOTO :EOF


:CLEAN
REM https://stackoverflow.com/questions/61212/how-do-i-remove-local-untracked-files-from-the-current-git-working-tree

git clean -fdx

GOTO :EOF
