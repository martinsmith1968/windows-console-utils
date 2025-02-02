@ECHO OFF

SETLOCAL EnableDelayedExpansion

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
ECHO.%~n0 - Generate a URL shortcut file
ECHO.
ECHO.%~n0 [url] { [filename] }

GOTO :EOF
