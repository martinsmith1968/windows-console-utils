@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET NIRCMD=nircmd


:PROCESS
IF /I "%~1" == "/?"       CALL :USAGE && GOTO :EOF
IF /I "%~1" == "-?"       CALL :USAGE && GOTO :EOF
IF /I "%~1" == "CLEAR"    CALL :RUN clear && GOTO :EOF
IF /I "%~1" == "SET"      CALL :RUN set "%~2" && GOTO :EOF
IF /I "%~1" == "NAME"     CALL :SETNAME "%~2" "%~3" && GOTO :EOF
IF /I "%~1" == "FILENAME" CALL :SETNAME "%~2" "%~3" && GOTO :EOF
IF /I "%~1" == "READ"     CALL :RUN readfile "%~2" && GOTO :EOF
IF /I "%~1" == "SAVE"     CALL :CLEARFILE "%~2" && CALL :RUN addfile "%~2" && GOTO :EOF
IF /I "%~1" == "APPEND"   CALL :RUN addfile "%~2" && GOTO :EOF

IF NOT "%~1" == "" CALL :ERROR Unknown command: %~1

CALL :USAGE

GOTO :EOF


:RUN
"%NIRCMD%" clipboard %~1 %~2

GOTO :EOF


:SETNAME
CALL :RUN set "%~dpnx1"

GOTO :EOF


:CLEARFILE
IF EXIST "%~1" DEL "%~1"

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Manipulate the Clipboard (using NIRCMD)
ECHO.
ECHO.Usage: %~n0 [command] { [parameters] }
ECHO.
ECHO.Commands:
ECHO. CLEAR           - Clear the clipboard
ECHO. SET [text]      - Set the text on the clipboard
ECHO. NAME [filename] - Set the filename on the clipboard
ECHO. READ [filename] - Read the text from [filename] onto the clipboard
ECHO. SAVE [filename] - Save the text from the clipboard into [filename]

GOTO :EOF


:ERROR
ECHO.Error: %*
GOTO :EOF
