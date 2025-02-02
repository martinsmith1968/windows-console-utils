@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET POS=0

SET FOLDER=
SET QUIET=N
SET STRICT=N

:PARSEOPTS
IF /I "%~1" == "/Q" SET QUIET=Y&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-Q" SET QUIET=Y&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/S" SET STRICT=Y&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-S" SET STRICT=Y&&SHIFT && GOTO :PARSEOPTS

SET /A POS+=1

IF %POS% EQU 1 SET FOLDER=%~1&&SHIFT && GOTO :PARSEOPTS

:VALIDATE
IF "%FOLDER%" == "" (
  CALL :USAGE
  CALL :ERROR "[folder] not specified" 
  GOTO :EOF
)

:GO
IF EXIST "%FOLDER%\*.*" (
  IF "%STRICT%" == "Y" (
    CALL :ERROR "[%FOLDER%] already exists
    GOTO :EOF
  )
)
IF NOT EXIST "%FOLDER%\*.*" (
  IF "%QUIET%" == "N" ECHO.Creating: %FOLDER%
  MD "%FOLDER%"
)
IF EXIST "%FOLDER%\*.*" (
  IF "%QUIET%" == "N" ECHO.Switching to: %FOLDER%
  ENDLOCAL && CD "%FOLDER%"
)

GOTO :EOF


:USAGE
ECHO.%~n0 - Create and Change to a new directory
ECHO.
ECHO.%~n0 [folder] { [switches] }
ECHO.
ECHO.Switches:
ECHO.-Q  - Quiet mode - do not display messages
ECHO.-S  - Strict mode - abort if [folder] already exists
ECHO.
GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
