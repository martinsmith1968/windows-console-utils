@ECHO OFF

SETLOCAL EnableExtensions EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
  CALL :USAGE
  GOTO :EOF
)

SET TXT=%~1

IF NOT "%ConEmuIsAdmin%" == "" (
  SET TXT=!TXT! ^(%ConEmuIsAdmin%^)
)

TITLE %TXT%

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Set the Console Window Title (Allowing for ConEmu Admin consoles)
ECHO.
ECHO.%SCRIPTNAME% [title]

GOTO :EOF
