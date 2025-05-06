@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET DRYRUN=N
SET HELP=N
SET ARGPOS=0

SET COMMANDPREFIX=
SET CONFIGURATION=
SET APPARGS=

REM Commands:
REM
REM c - clean
REM r - restore
REM b - build
REM t - test

:PARSE
IF /I "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/C" SET CONFIGURATION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-C" SET CONFIGURATION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/A" SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-A" SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1

IF %ARGPOS% EQU 1 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE

IF "%HELP%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

CALL :USAGE
CALL :ERROR "Unexpected argument as pos %ARGPOS% : %~1"
GOTO :EOF


:VALIDATE
IF "%COMMAND%" == "" (
  CALL :USAGE
  GOTO :EOF
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

:GO
IF /I "%COMMAND%" == "rebuild"      GOTO :COMMAND_REBUILD
IF /I "%COMMAND%" == "rb"           GOTO :COMMAND_REBUILD
IF /I "%COMMAND%" == "cb"           GOTO :COMMAND_REBUILD
IF /I "%COMMAND%" == "rebuildtest"  GOTO :COMMAND_REBUILDTEST
IF /I "%COMMAND%" == "rbt"          GOTO :COMMAND_REBUILDTEST
IF /I "%COMMAND%" == "cbt"          GOTO :COMMAND_REBUILDTEST
IF /I "%COMMAND%" == "run"          GOTO :COMMAND_RUN
IF /I "%COMMAND%" == "r"            GOTO :COMMAND_RUN
IF /I "%COMMAND%" == "ver"          GOTO :COMMAND_VER
IF /I "%COMMAND%" == "v"            GOTO :COMMAND_VER

CALL :ERROR "Invalid or Unknown command : %COMMAND%"
GOTO :EOF


:COMMAND_REBUILD
SET EXTRA=
if NOT "%CONFIGURATION%" == "" SET EXTRA=-c %CONFIGURATION%

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet clean %EXTRA%
%COMMANDPREFIX%dotnet build %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:COMMAND_REBUILDTEST
CALL :COMMAND_REBUILD

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet test %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:COMMAND_RUN
SET EXTRA=
IF NOT "%APPARGS%" == "" SET EXTRA=-- %APPARGS%

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet run %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:COMMAND_VER
SET APP=%SCRIPTPATH%\..\win\dotnetver.exe

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%START "" "%APP%"
%COMMANDPREFIX%dotnet --info
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - .NET command helper
ECHO.Usage: %~n0 [command] [options]
ECHO.
ECHO.Commands:
ECHO.rebuild     - clean and rebuild a solution (Shortcut: rb / cb)
ECHO.rebuildtest - clean, rebuild and test a solution (Shortcut: rbt / cbt)
ECHO.run         - run a project (Shortcut: r)
ECHO.
ECHO.Options:
ECHO./C [configuration] - Set the build configuration
ECHO./A [arguments]     - Add the arguments 

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
