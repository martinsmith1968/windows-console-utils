@ECHO OFF

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

IF NOT EXIST "%~1" (
    CALL :ERROR "Folder does not exist - %~1"
    GOTO :EOF
)

IF NOT EXIST "%~1\*.sln" (
    CALL :ERROR "Solution not found in this location - %~1"
    GOTO :EOF
)

CALL :CLEANSOLUTIONFOLDER "%~1"

GOTO :EOF


:USAGE
ECHO %~n0 - Remove all binary and intermediate files and folders from a solution
ECHO.
ECHO.Usage:
ECHO.%~n0 [solution-folder-name]
ECHO.
BANNERTEXT "%~n0 is obsolete. Use CleanVSSolution and CleanVSProject commands instead"
GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:CLEANSOLUTIONFOLDER
IF "%~1" == "" GOTO :EOF

FOR /D %%F IN ("%~1\*.*") DO (
    CALL :CLEARDIR "%%~F\bin"
    CALL :CLEARDIR "%%~F\obj"
)

FOR /D %%F IN ("%~1\x64\*.*") DO (
    CALL :CLEARDIR "%%~F\bin"
    CALL :CLEARDIR "%%~F\obj"
)

GOTO :EOF


:CLEARDIR
ECHO.Clearing: %~1

IF EXIST "%~1\*.*" DEL /F /S /Q "%~1\*.*"


GOTO :EOF
