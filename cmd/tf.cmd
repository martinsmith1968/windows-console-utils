@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET HOMEDIR=C:\ProgramData\Terraform

SET HELP=N
SET DEBUG=N
SET LIST=N
SET VERSION=173
SET PARAMETERS=

FOR %%* IN (%HOMEDIR%\*.default_version) DO SET VERSION=%%~n*


:PARSEOPTIONS
IF /I "%~1" == "/?" SET HELP=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-?" SET HELP=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/x" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-x" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/v" SET VERSION=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-v" SET VERSION=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/l" SET LIST=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-l" SET LIST=Y&& SHIFT && GOTO :PARSEOPTIONS

IF "%~1" == "" GOTO :VALIDATE

SET PARAMETERS=%PARAMETERS% %1

SHIFT
GOTO :PARSEOPTIONS


:VALIDATE
SET EXECUTABLE=terraform%VERSION%.exe
IF "%DEBUG%" == "Y" ECHO.EXECUTABLE=%EXECUTABLE%

:EXECUTE
IF "%HELP%" == "Y" (
    CALL :USAGE
    GOTO :EOF
)

IF "%LIST%" == "Y" (
    CALL :LISTVERSIONS
    GOTO :EOF
)

IF "%DEBUG%" == "Y" ECHO.PARAMETERS=%PARAMETERS%
%EXECUTABLE% %PARAMETERS%

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Execute Terraform allowing version selection
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [Extension] { [options] }
ECHO.
ECHO.Options: [/-] prefix supported
ECHO. /x  - Turn on Debugging
ECHO. /l  - List Available versions
ECHO. /v  - Version (Default: %VERSION%)
ECHO.
ECHO.Use: %SCRIPTNAME% --version to see the exact terraform version

GOTO :EOF


:LISTVERSIONS
ECHO.Available Versions:
@IF "%DEBUG%" == "Y" @ECHO ON
DIR /b "%HOMEDIR%\*.exe" /on | sed -e "s/terraform//g" -e "s/.exe//g" | grep -v "^$" | sed -e "s/^/- /g"
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:ERROR
ECHO.ERROR: %*
GOTO :EOF
