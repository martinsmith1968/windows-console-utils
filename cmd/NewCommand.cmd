@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET LIB=%~dp0\lib.cmd

CALL %LIB% SETUP "%~dpnx0" "A New Command to do something"
CALL %LIB% DEFINESTANDARDOPTIONSANDFLAGS
CALL %LIB% DEFINEKNOWNCOMMAND bob BOB "Bob is a placeholder command for testing."
CALL %LIB% DEFINEKNOWNFLAG reverse r "Reverse the order of the output."
CALL %LIB% DEFINEKNOWNOPTION count c "The number of times to repeat the output."

REM CALL %LIB% DEBUGINTERNALS

:PARSE
CALL %LIB% DEBUG "Parsing: %*"
IF "%~1" == "" GOTO :VALIDATE

CALL %LIB% PARSEARGUMENT "%~1" "%~2%"
IF %PARSEDCOUNT% == 0 (
    CALL %LIB% SHOWUSAGE
    CALL %LIB% ERROR "Unknown argument: %~1"
    EXIT /B 1
)

FOR /L %%I IN (1,1,%PARSEDCOUNT%) DO SHIFT

GOTO :PARSE


:VALIDATE
IF "%HELP%" == "Y" CALL %LIB% SHOWUSAGE && GOTO :EOF

ECHO.Executing....

CALL %LIB% SHOWUSAGE
