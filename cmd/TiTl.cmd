@ECHO OFF

SETLOCAL EnableExtensions EnableDelayedExpansion

SET HELP=N
SET POS=0
SET SOURCE=
SET PREFIX=
SET SUFFIX=
SET PATHREPLACEMENTCHAR=-

:PARSEOPTS
IF /I "%~1" == "/?" SET HELP=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-?" SET HELP=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-p" SET PREFIX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/p" SET PREFIX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-s" SET SUFFIX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/s" SET SUFFIX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-c" SET PATHREPLACEMENTCHAR=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/c" SET PATHREPLACEMENTCHAR=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS

SET /A POS+=1
IF NOT "%~1" == "" (
    IF %POS% EQU 1 (
        SET SOURCE=%~1
    ) ELSE (
       CALL :USAGE
       ECHO.ERROR: Unknown argument at position: %POS%: %~1
       GOTO :EOF
    )

    SHIFT
    GOTO :PARSEOPTS
)

:PARSESOURCE
IF /I "%SOURCE%" == "P"    CALL :SETSOURCEBYPATH "%CD%" && GOTO :GO
IF /I "%SOURCE%" == "PATH" CALL :SETSOURCEBYPATH "%CD%" && GOTO :GO
IF /I "%SOURCE%" == "N"    CALL :SETSOURCEBYNAME "%CD%" && GOTO :GO
IF /I "%SOURCE%" == "NAME" CALL :SETSOURCEBYNAME "%CD%" && GOTO :GO
IF /I "%SOURCE%" == "E"    CALL :SETSOURCEBYEXT "%CD%" && GOTO :GO
IF /I "%SOURCE%" == "EXT"  CALL :SETSOURCEBYEXT "%CD%" && GOTO :GO

:GO
IF "%SOURCE%" == "" (
    CALL :USAGE
    GOTO :EOF
)

CALL :SET "%PREFIX%%SOURCE%%SUFFIX%"

GOTO :EOF


:SETSOURCEBYPATH
SET BITS=%~pn1
SET BITS=%BITS:\=,%
SET NAME=
SET SEP=%~2

FOR %%I in (%BITS%) DO (
    IF NOT "!NAME!" == "" (
        SET NAME=!NAME!!SEP!
    )
    SET NAME=!NAME!%%I
)

SET SOURCE=%NAME%

GOTO :EOF


:SET
IF "%~1" == "" GOTO :EOF

CALL SETTITLE.CMD "%~1"

GOTO :EOF


:SETSOURCEBYNAME
SET SOURCE=%~nx1
GOTO :EOF


:SETBYEXT
SET SOURCE=%~x1
GOTO :EOF


:USAGE
ECHO.%~n0 - Set the Console Window Title using current directory
ECHO.
ECHO.%~n0 [command] { [switches] }
ECHO.
ECHO.Commands:
ECHO.P[ATH]     - Set By Full Directory Path
ECHO.N[AME]     - Set By Directory Name
ECHO.E[XT]      - Set by Directory Extension
ECHO.{other}    - Use {other} as Title Text
ECHO.
ECHO.Switches:
ECHO.-P [text]  - Use [text] as a prefix
ECHO.-S [text]  - Use [text] as a suffix
ECHO.-C [char]  - Use [char] as a replacement for \ in Paths (Default: %PATHREPLACEMENTCHAR%)
ECHO.
GOTO :EOF
