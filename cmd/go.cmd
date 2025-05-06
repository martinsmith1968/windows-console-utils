@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpnx*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~nx*

:INIT
SET HELP=N
SET DEBUG=N
SET DRYRUN=N
SET VERBOSE=Y
SET ARGPOS=0
SET FOLDER=.
SET NAMEFILTER=
SET EXTENSION=exe
SET ARGS=

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V-" SET VERBOSE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V-" SET VERBOSE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/N" SET NAMEFILTER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-N" SET NAMEFILTER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/E" SET EXTENSION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-E" SET EXTENSION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS += 1

SET ARGS=%ARGS% %~1&&SHIFT&&GOTO :PARSE

CALL :ERROR "Unexpected argument as position %ARGPOS%: %~1"
GOTO :EOF


:VALIDATE
IF "%HELP%" == "Y" (
    CALL :USAGE
    GOTO :EOF
)


:GO
CALL :FINDTARGET

IF %TARGETCOUNT% EQU 0 (
    CALL :ERROR "No target executable found"
    GOTO :EOF
)

IF %TARGETCOUNT% GTR 1 (
    CALL :ERROR "Multiple target executables found"
    TYPE "%UNIQUETEMPFILENAME%
    GOTO :EOF
)

SET COMMANDPREFIX=
IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

IF "%VERBOSE%" == "Y" ECHO.Executing: %TARGETFILENAME% %ARGS%
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%%TARGETFILENAME% %ARGS%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Execute a file without having to type its full NAMEFILTER
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [options] { [argument] ... { [argument] } }
ECHO.
ECHO.Options:
ECHO. /N [name] Filter by filename [name]
ECHO. /E [ext]  Filter by extension [ext]
ECHO. /V[-]     Activate / Deactivate Verbose mode (Default: %VERBOSE%)
ECHO. /X        Activate Debug mode (Default: %DEBUG%)
ECHO. /Z        Activate DruRun mode (Default: %DRYRUN%)
ECHO.
ECHO.Arguments:
ECHO. Provide as an argument to the found target executable
ECHO.
ECHO.Notes
ECHO. Target does not have to be an executable - target will be launched with default "Open" command
GOTO :EOF


:ERROR
ECHO.ERROR: %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8
GOTO :EOF


:FINDTARGET
SET TARGETCOUNT=0
SET TARGETFILENAME=

PUSHD "%FOLDER%"

CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.tmp"

@IF "%DEBUG%" == "Y" @ECHO ON
DIR "*.%EXTENSION%" /b 1> "%UNIQUETEMPFILENAME%" 2>NUL
@IF "%DEBUG%" == "Y" @ECHO OFF

@IF "%DEBUG%" == "Y" @ECHO ON
IF NOT "%NAMEFILTER%" == "" (
    IF "%VERBOSE%" == "Y" ECHO.Filtering: %NAMEFILTER%
    TYPE "%UNIQUETEMPFILENAME%" | GREP -i "%NAMEFILTER%" > "%UNIQUETEMPFILENAME%2"
    SET UNIQUETEMPFILENAME=%UNIQUETEMPFILENAME%2
)
@IF "%DEBUG%" == "Y" @ECHO OFF

@IF "%DEBUG%" == "Y" @ECHO ON
FOR /F %%F IN (%UNIQUETEMPFILENAME%%) DO (
    ECHO.Found candidate: %%~F
    SET /A TARGETCOUNT += 1
    IF "!TARGETFILENAME!" == "" SET TARGETFILENAME=%%~F
)
@IF "%DEBUG%" == "Y" @ECHO OFF

POPD

GOTO :EOF
