@ECHO OFF

SETLOCAL EnableExtensions EnableDelayedExpansion

SET SCRIPTPATH=%~dp0

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
ECHO.%~n0 - Set the Console Window Title (Allowing for ConEmu Admin consoles)
ECHO.
ECHO.%~n0 [title]

GOTO :EOF
