@ECHO OFF

SETLOCAL

SET POS=1
SET TARGET=
SET DEBUG=N

:PARSEOPTS
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
    IF %POS% EQU 1 (
        SET TARGET=%~1
        SET TARGETNAME=%~nx1
        SET TARGETDIRECTORY=%~dpnx1
    ) ELSE (
        CALL :ERROR "Unknown argument at pos %POS%
        GOTO :EOF
    )
    
    SET /A POS+=1
    SHIFT
    GOTO :PARSEOPTS
)

:START
IF "%TARGET%" == "" (
    CALL :USAGE
    GOTO :EOF
)

IF NOT EXIST "%TARGET%\*.*" (
    CALL :ERROR "Directory not found: %TARGET%"
    CALL :USAGE
    GOTO :EOF
)

CALL FINDAPP.CMD Programs "Microsoft VS Code" code.exe
IF "%APP%" == "" (
    CALL :ERROR "Unable to locate VSCode"
    CALL :USAGE
    GOTO :EOF
)

SET FILENAME=VSCode - %TARGETNAME%.lnk

IF EXIST "%FILENAME%" DEL /F /Q "%FILENAME%"

@IF "%DEBUG%" == "Y" @ECHO ON
SHORTCUT /A:C /F:"%FILENAME%" /T:"%APP%" /P:"%TARGETDIRECTORY%" /W:"%TARGETDIRECTORY%" /D:"Open VSCode for %TARGET%" /I:"%APP%,0" >NUL
@IF "%DEBUG%" == "Y" @ECHO OFF

SHORTCUT /A:Q /F:"%FILENAME%"

GOTO :EOF


:USAGE
ECHO.%~n0 - Generate a VSCode link to a directory
ECHO.
ECHO.%~n0 [dir]

GOTO :EOF


:ERROR
ECHO.Error: %~1
ECHO.

GOTO :EOF
