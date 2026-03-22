@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET NIRCMD=nircmd

SET HELP=N
SET DEBUG=N

SET INDEX=0
SET CMD=
SET ARG1=

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?"       SET HELP=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-?"       SET HELP=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/X"       SET DEBUG=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-X"       SET DEBUG=Y&&SHIFT && GOTO :PARSE

IF /I "%~1" == "CLEAR"    SET CMD=clear&& SHIFT && GOTO :PARSE
IF /I "%~1" == "SET"      SET CMD=set&& SET ARG1=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "FILENAME" SET CMD=set&& CALL :SETBYFILENAME "%~2" && SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "NAME"     SET CMD=set&& CALL :SETBYNAME "%~2" && SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "PATH"     SET CMD=set&& CALL :SETBYPATH "%~2" && SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "READ"     SET CMD=readfile&& SET ARG1=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "SAVE"     CALL :CLEARFILE "%~2" && SET CMD=addfile&& SET ARG1=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "APPEND"   SET CMD=addfile&& SET ARG1=%~2&& SHIFT && SHIFT && GOTO :PARSE

SET /A INDEX += 1

CALL :ERROR Unknown command at postion %INDEX%: %~1
CALL :USAGE
GOTO :EOF


:VALIDATE
IF "%HELP%" == "Y" CALL :USAGE && GOTO :EOF
IF "%CMD%" == "" CALL :USAGE "No command specified." && GOTO :EOF

@IF "%DEBUG%" == "Y" @ECHO ON
"%NIRCMD%" clipboard "%CMD%" "%ARG1%"
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:SETBYFILENAME
SET ARG1=%~dpnx1
GOTO :EOF


:SETBYNAME
SET ARG1=%~nx1
GOTO :EOF


:SETBYPATH
SET ARG1=%~dp1
GOTO :EOF


:CLEARFILE
IF EXIST "%~1" DEL "%~1"

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Manipulate the Clipboard (using NIRCMD)
ECHO.
ECHO.Usage: %SCRIPTNAME% [command] { [parameters] }
ECHO.
ECHO.Commands:
ECHO. CLEAR               - Clear the clipboard
ECHO. SET [text]          - Set the text on the clipboard
ECHO. FILENAME [filename] - Set the full filename on the clipboard
ECHO. NAME [filename]     - Set the filename and exension on the clipboard
ECHO. PATH [filename]     - Set the Path of the filename on the clipboard
ECHO. READ [filename]     - Read the text from [filename] onto the clipboard
ECHO. SAVE [filename]     - Save the text from the clipboard into [filename]

IF NOT "%~1" == "" (
    ECHO.
    CALL :ERROR "%~1"
)

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
