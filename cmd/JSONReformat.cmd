@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1"=="" (
    ECHO Usage: %SCRIPTNAME% [input_file] 
    EXIT /B 1
)

TYPE "%~1" | jq "."
