@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET EXECUTE=Y
SET COMMAND=

SET TARGETFORMAT=

SET ARGPOS=0


:PARSE
IF /I "%~1" == "/x" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-x" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/z" SET EXECUTE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-z" SET EXECUTE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tf" SET TARGETFORMAT=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tf" SET TARGETFORMAT=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

IF "%~1" == "" GOTO :VALIDATE
SET /A ARGPOS+=1

:POSITIONAL
IF %ARGPOS% == 1 (
  SET COMMAND=%~1
  SHIFT
  IF "!TARGETFORMAT!" == "" SET TARGETFORMAT=MP3
  GOTO :PARSE
)

:UNEXPECTED
CALL :ERROR "Unexpected or unknown parameter: %~1"
GOTO :EOF


:VALIDATE
IF "%COMMAND%" == "" (
  CALL :USAGE
  CALL :ERROR "No Command specified"
  GOTO :EOF
)


:GO
GOTO :GO_%COMMAND%>NUL

CALL :ERROR "Command not recognised: %COMMAND%"
GOTO :EOF


:GO_FLAC
FOR %%F IN (*.flac) DO ffmpeg -i "%~nxF" "%~nF.%TARGETFORMAT%"

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF

:USAGE
ECHO.%SCRIPTNAME% - Convert a file via FFMPEG
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [command] [options]
ECHO.
ECHO.Global Options:
ECHO./X    - Enable Debug mode
ECHO./Z    - Show execution command (Do NOT execute)
ECHO.
ECHO.Command:
ECHO.FLAC  - Convert a FLAC file to another format (E.g. MP3)
ECHO.  /TF - Target Format (Default: MP3)

GOTO :EOF
