@ECHO OFF

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET POS=0
SET SHELL=Shells::cmd
SET ARGS=

:PARSEOPTS
REM TODO

IF "%~1" == "" GOTO :GO

SET /A POS=+1

IF %POS% EQU 1 (
    SET SHELL=%~1&&SHIFT
) ELSE (
    SET ARGS=%ARGS% "%~1"
)
SHIFT
GOTO :PARSEOPTS

:GO
"%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "ConEMU" /e "conemu64.exe" /f "ConEmu" /d "Start a new console tab in ConEMU" /od "{ [shell] }" /oa "type  Console Shell" /rac 0 /nqa -run {%SHELL%} %ARGS%
