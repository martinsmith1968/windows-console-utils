@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET MODE=npm
SET DEBUG=N
SET POS=1

:PARSE
IF /I "%~1" == "/X" SET DEBUG=Y && SHIFT
IF /I "%~1" == "-X" SET DEBUG=Y && SHIFT
IF /I "%~1" == "/M" SET MODE=%~2 && SHIFT && SHIFT
IF /I "%~1" == "-M" SET MODE=%~2 && SHIFT && SHIFT

IF NOT "%~1" == "" (
  IF %POS% == 1 (
    SET FILE=%~1
  )
  
  SHIFT
)

IF NOT "%~1" == "" GOTO :PARSE

IF "%FILE%" == "" CALL :USAGE && GOTO :EOF

SET COMMAND=
IF /I "%MODE%" == "docker" SET COMMAND=docker run --rm -p 2525:2525 -p 8080:8080 -v "%CD%:/data" bbyars/mountebank mb start "/data/%FILENAME%"
IF /I "%MODE%" == "npm"    SET COMMAND=mb start "%FILENAME%"

:GO
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMAND%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Run Mountebank using a specific config file via Docker / npm
ECHO.
ECHO.%SCRIPTNAME% [filename] [options]
ECHO.
ECHO.Options:
ECHO.
ECHO./M [mode] - Execution mode (docker / npm) Default: %MODE%
ECHO./X        - Debug mode

GOTO :EOF
