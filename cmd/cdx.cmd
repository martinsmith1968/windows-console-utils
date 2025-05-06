@ECHO OFF

SETLOCAL

SET HELP=N
SET WILDCARD=
SET RECURSE=Y

SET POSITION=1

:PARSEARGS
IF /I "%~1" == "/?" (
    SET HELP=Y
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "/S" (
    SET RECURSE=Y
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "/S-" (
    SET RECURSE=N
    SHIFT
    GOTO :PARSEARGS
)

IF NOT "%~1" == "" (
  IF %POSITION% EQU 1 SET WILDCARD=*.%~1
  
  SET /A POSITION+=1
  SHIFT
  GOTO :PARSEARGS
)

IF /I "%HELP%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)
IF "%WILDCARD%" == "" (
  CALL :USAGE
  CALL :ERROR Missing wildcard
  GOTO :EOF
)

FOR /R %%F IN (%WILDCARD%) DO (
  ECHO.Found: %%~dpnxF
  ENDLOCAL && CD /D "%%~dpF"
  GOTO :EXIT
)

:EXIT
EXIT /B
GOTO :EOF


:CD
ENDLOCAL
@ECHO ON
ECHO.Changing to: %~1
CD /D "%~1"

GOTO :EOF


:USAGE
ECHO.%~n0 - CD to a folder based on first match of a file wildcard
ECHO.
ECHO.Usage:
ECHO/%~n0 [wildcard] [options]
ECHO.
ECHO.Options:
ECHO./S     Recurse subdirectories (/S- to not)

GOTO :EOF


:ERROR
ECHO.
ECHO.ERROR: %*
GOTO :EOF
