@ECHO OFF

REM Loosely based on : https://conemu.github.io/en/LaunchNewTab.html#Create_new_tab_from_existing_one
REM                  : https://conemu.github.io/en/NewConsole.html

SETLOCAL

SET SCRIPTNAME=%~n0
SET SCRIPTPATH=%~dp0

SET POS=0
SET SHELL=Shells::cmd

SET USEINJECTHOOK=N

SET ARGS=

:PARSEOPTS
IF "%~1" == "" GOTO :GO
IF "%+1" == "/?" SET HELP=Y&& SHIFT && GOTO :PARSEOPTS

SET /A POS=+1

IF %POS% EQU 1 (
    SET SHELL=%~1&&SHIFT
) ELSE (
    SET ARGS=%ARGS% "%~1"
)
SHIFT
GOTO :PARSEOPTS

:GO
IF "%USEINJECTHOOK%" == "Y" (
    CALL cmd -new_console 
) ELSE (
    "%SCRIPTPATH%\StartApp.cmd" /n "%SCRIPTNAME%" /t "ConEMU" /e "conemu64.exe" /f "ConEmu" /d "Start a new console tab in ConEMU" /od "{ [shell] }" /oa "type  Console Shell" /rac 0 /nqa -run {%SHELL%} %ARGS%
)
