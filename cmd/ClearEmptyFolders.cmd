@ECHO OFF

SETLOCAL

REM https://recoverit.wondershare.com/file-recovery/delete-empty-folders-in-windows.html

SET FOLDER=
SET FLAGS=
SET ARGPOS=0

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/L" SET FLAGS=%FLAGS% /L&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-L" SET FLAGS=%FLAGS% /L&&SHIFT && GOTO :PARSE

SET /A ARGPOS+=1

IF %ARGPOS% EQU 1 (
  SET FOLDER=%~1
  SHIFT
  GOTO :PARSE
)

CALL :ERROR "Unexpected argument : %~1"
GOTO :EOF


:VALIDATE
IF "%FOLDER%" == "" (
    CALL :USAGE
    GOTO :EOF
)


:GO
ECHO.>"%FOLDER%\Robocopy.tmp"
ROBOCOPY "%FOLDER%" "%FOLDER%" /S /MOVE /R:1 /W:1 /NJH /NJS /XF robocopy.tmp /XD .git %FLAGS%
DEL /Q "%FOLDER%\Robocopy.tmp"

GOTO :EOF


:USAGE
ECHO.%~n0 - Remove all empty folders under a top-level folder
ECHO.
ECHO.Usage:
ECHO/%~n0 [folder] [options]
ECHO.
ECHO.Options:
ECHO./L     List folders to be deleted only (Non-destructive)
ECHO.
ECHO.Notes
ECHO.- Uses Robocopy to move a folder to itself and remove non-matching in the target

GOTO :EOF


:ERROR
ECHO.ERROR: %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8
GOTO :EOF
