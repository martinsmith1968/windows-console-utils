REM @ECHO OFF

SETLOCAL

SET DEBUG=N
SET KEYNAME=
SET FILENAME=
SET ARGPOS=0

SET VALUE=

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/F" SET FILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-F" SET FILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1

IF %ARGPOS% EQU 1 SET KEYNAME=%~1&&SHIFT&&GOTO :PARSE

CALL :ERROR "Unexpected parameter at position %ARGPOS%: %~1"
GOTO :EOF


:VALIDATE
IF "%KEYNAME%" == "" (
	CALL :USAGE
	CALL :ERROR "KeyName not specified"
	GOTO :EOF
)


:GO
IF NOT EXIST "%FILENAME%" GOTO :EOF

@IF "%DEBUG%" == "Y" @ECHO ON
FOR /f %%D IN ('yq -r "%KEYNAME%" "%FILENAME%"') DO SET VALUE=%%D
@IF "%DEBUG%" == "Y" @ECHO OFF

ENDLOCAL && SET TOMLVALUE=%VALUE%

GOTO :EOF


:USAGE
ECHO.%~n0 - Get a value from a TOML file
ECHO.
ECHO.%~n0 [keyname] [options]
ECHO.
ECHO.Options:
ECHO.-f [filename]		The filename to read from

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
