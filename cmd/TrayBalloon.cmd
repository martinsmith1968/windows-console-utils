@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTFILE=%~nx0
SET SCRIPTNAME=%~n0

IF "%~1" == "" (
  CALL :USAGE
  GOTO :EOF
)

SET MESSAGE=%~1
SET TIMEOUT=%~2
SET TITLE=%~3
SET ICON=%~4

IF "%TIMEOUT%" == "" (
  SET TIMEOUT=5
)

IF "%ICON%" == "" (
  SET ICON=shell32.dll,34
)

IF %TIMEOUT% LSS 1000 (
  SET /A TIMEOUT=%TIMEOUT% * 1000
)

REM ECHO.START "TrayBalloon" NIRCMD TrayBalloon "%TITLE%" "%MESSAGE%" "%ICON%" %TIMEOUT%
START "TrayBalloon" NIRCMD TrayBalloon "%TITLE%" "%MESSAGE%" "%ICON%" %TIMEOUT%

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Display a message as a Tray Balloon
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% "message" [ timeout [ "title" [ "icon" ] ] ]
ECHO.
ECHO.Notes:
ECHO.Timeout is in seconds  (default: 5)
ECHO.Icon is of the format: (default: shell32.dll,34)
ECHO.  shell32.dll,22  or  icon1.ico

GOTO :EOF
