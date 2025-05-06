@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

SET COMMAND=%~1
SET TARGET=

IF /I "%COMMAND%" == "GETVER" SET TARGET=%COMMAND%
IF /I "%COMMAND%" == "SETVER" SET TARGET=%COMMAND%
IF /I "%COMMAND%" == "INCVER" SET TARGET=%COMMAND%

IF NOT "%TARGET%" == "" (
    SHIFT
    GOTO :%TARGET%
)

CALL :ERROR Unknown Command: %~1
CALL :USAGE
GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Manipulate NuSpec files
ECHO.
ECHO.%SCRIPTNAME% [command] [filename] [OPTIONS]
ECHO.
ECHO.COMMANDS:
ECHO.GETVER     Retrieve the current version number
ECHO.SETVER     Set the current version number
ECHO.INCVER     Increment the current version number
ECHO.
ECHO.
ECHO.SETVER:
ECHO.[newversion]   - The new version number to set
ECHO.
ECHO.INCVER:
ECHO./MAJOR         - Increment the Major version
ECHO./MINOR         - Increment the Minor version
ECHO./PATCH         - Increment the Patch version
ECHO./RELEASE       - Increment the Release version (Default)
GOTO :EOF


:ERROR
ECHO.ERROR: %*

GOTO :EOF


:GETVER
SET FILENAME=%~1

xml sel -t -m "/package/metadata" -v "version" "%FILENAME%"

GOTO :EOF


:SETVER
SET FILENAME=%~1
SET NEWVER=%~2

IF "%~2" == "" (
    CALL :ERROR Invalid Version Number: %~2
    GOTO :EOF
)

COPY /Y "%FILENAME%" "%FILENAME%.bak" > NUL

xml ed -u "/package/metadata/version" -v "%NEWVER%" "%FILENAME%.bak" > "%FILENAME%"

ECHO.%~nx1: Version=%NEWVER%

GOTO :EOF


:INCVER
SET FILENAME=%~1

SET MODE=RELEASE
IF /I "%~2" == "/MAJOR" SET MODE=MAJOR
IF /I "%~2" == "/MINOR" SET MODE=MINOR
IF /I "%~2" == "/PATCH" SET MODE=PATCH
IF /I "%~2" == "/RELEASE" SET MODE=RELEASE

FOR /F %%F IN ('CALL "%SCRIPTFULLFILENAME%" GETVER "%FILENAME%"') DO SET CURRENTVERSION=%%F

FOR /F "delims=. tokens=1-5" %%A IN ("%CURRENTVERSION%") DO (
    SET VERMAJOR=%%A
    SET VERMINOR=%%B
    SET VERPATCH=%%C
    SET VERRELEASE=%%D
    SET VERSUFFIX=%%E
)

IF "%MODE%" == "RELEASE" (
    SET /A VERRELEASE+=1
) ELSE IF "%MODE%" == "PATCH" (
    SET /A VERPATCH+=1
) ELSE IF "%MODE%" == "MINOR" (
    SET /A VERMINOR+=1
) ELSE IF "%MODE%" == "MAJOR" (
    SET /A VERMAJOR+=1
)
SET NEWVER=%VERMAJOR%.%VERMINOR%.%VERPATCH%.%VERRELEASE%

CALL "%SCRIPTFULLFILENAME%" SETVER "%FILENAME%" "%NEWVER%"

GOTO :EOF
