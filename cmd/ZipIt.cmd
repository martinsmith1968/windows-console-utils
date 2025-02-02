@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTFILE=%~nx0
SET SCRIPTNAME=%~n0

IF "%~1" == "-?" (
    CALL :USAGE
    GOTO :EOF
)
IF "%~1" == "/?" (
    CALL :USAGE
    GOTO :EOF
)

SET FILESPEC=%~1
IF "%FILESPEC%" == "" (
    SET FILESPEC=*.*
)

SET CURDIR=%~2
IF "%CURDIR%" == "" (
    FOR %%* IN (.) DO SET CURDIR=%%~nx*
)

SET OPTIONS=%~3
IF "%OPTIONS%" == "" (
    SET OPTIONS=-D
)

ZIP %OPTIONS% %CURDIR%.zip %FILESPEC% -x %CURDIR%.zip

GOTO :EOF

:USAGE
ECHO.%SCRIPTNAME% - Compress the files in the current folder
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [ filespec [ ArchiveName ] ]
ECHO.
ECHO.FileSpec defaults to *.*
ECHO.Archive name defaults to current folder name
