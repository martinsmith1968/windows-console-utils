@ECHO OFF

SETLOCAL

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET NUSPECNAME=%~1
SET NUSPECCOUNT=1

IF "%NUSPECNAME%" == "" (
    CALL :LOCATENUSPEC
) ELSE IF NOT EXIST "%NUSPECNAME%" (
    CALL :LOCATENUSPEC
)

IF "%NUSPECNAME%" == "" (
    CALL :USAGE
    IF %NUSPECCOUNT% GTR 0 (
        ECHO.
        ECHO.Available NuSpec:
        ECHO.
        DIR /B *.nuspec
    )
    GOTO :EOF
)

CALL NuSpecEdit.cmd INCVER "%NUSPECNAME%"

NUGET PACK "%NUSPECNAME%"

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - NuGet Package Helper
ECHO.
ECHO.%SCRIPTNAME% [nuspec-filename] [OPTIONS]
ECHO.
ECHO.OPTIONS:
ECHO./I [increment-type]    Increment NuSpec version type (Default: /RELEASE)
ECHO./NI                    Don't Increment NuSpec version number

GOTO :EOF


:LOCATENUSPEC
SET NUSPECNAME=
SET NUSPECCOUNT=0

FOR %%F IN (%CURRENTDIR%\*.nuspec) DO (
    SET /A NUSPECCOUNT+=1
    SET NUSPECNAME=%%~F
)

IF %NUSPECCOUNT% GTR 1 (
    SET NUSPECNAME=
)

GOTO :EOF
