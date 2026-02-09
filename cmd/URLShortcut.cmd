@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
  CALL :USAGE
  GOTO :EOF
)

FOR /F "delims=#" %%F IN ("%~n1") DO (
  SET FILENAME=%%F.url
)
IF NOT "%~2" == "" (
  SET FILENAME=%~2
)
    
ECHO.[InternetShortcut]>%FILENAME%
ECHO.URL=%~1>>%FILENAME%

ECHO.
ECHO.File: %FILENAME% written

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Generate a URL shortcut file
ECHO.
ECHO.%SCRIPTNAME% [url] { [filename] }

GOTO :EOF
