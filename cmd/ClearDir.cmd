@ECHO OFF

SETLOCAL

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

SET KILLFOLDER=N

:PARSEOPTIONS
IF /I "%~2" == "/K" SET KILLFOLDER=Y
IF /I "%~2" == "-K" SET KILLFOLDER=Y

SHIFT /2

IF NOT "%~2" == "" GOTO :PARSEOPTIONS

CALL :CLEARFOLDER "%~1"

GOTO :EOF


:USAGE
ECHO %~n0 - Remove all files and subfolders from a folder
ECHO.
ECHO.Usage:
ECHO.%~n0 [folder-name] { /K - remove folder too }
GOTO :EOF


:CLEARFOLDER
IF "%~1" == "" GOTO :EOF
IF NOT EXIST "%~1" GOTO :EOF

ATTRIB -R -A -S -H "%~dpn1\*.*" >NUL
DEL /Q "%~dpn1\*.*" >NUL

FOR /D %%P IN ("%~dpn1\*.*") DO (
    ECHO.Clearing: %%~P
    RMDIR /S /Q "%%~P"
)

IF "%KILLFOLDER%" == "Y" (
    RMDIR "%~1"
)

GOTO :EOF
