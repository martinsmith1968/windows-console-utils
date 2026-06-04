@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM ********************************************************************************
REM ** TODO
REM 
REM ********************************************************************************

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET DRYRUN=N
SET HELP=N
SET ARGPOS=0
SET COMMANDPREFIX=
SET INTERNAL_ERROR=

SET QUIET=N
SET VERBOSE=N
SET VERYVERBOSE=N
SET TARGET=
SET PROFILE=dev
SET INCOMPATIBLEREPORT=

SET OUTPUTDIR=
SET PACKOUTPUTDIR=
SET NOBUILD=N
SET NORESTORE=N
SET LAUNCHPROFILE=
SET APPARGS=

SET COMMANDCOUNT=0
SET COMMANDSDESCRIPTION=

SET DEFINEDCOMMANDCOUNT=0
SET DEFINECOMMANDCOMBINATIONCOUNT=0

REM Commands:
REM
REM c - clean
REM f - fmt
REM i - fix
REM k - check
REM b - build
REM t - test
REM h - bench
REM l - publish
REM r - run
REM v - version

CALL :DEFINECOMMAND clean   c "Clean build outputs"
CALL :DEFINECOMMAND fmt     f "Format source code"
CALL :DEFINECOMMAND fix     i "Fix lint warnings"
CALL :DEFINECOMMAND check   k "Check lint warnings"
CALL :DEFINECOMMAND build   b "Build the current target"
CALL :DEFINECOMMAND test    t "Run tests for the current target"
CALL :DEFINECOMMAND bench   h "Run benchmarks for the current target"
CALL :DEFINECOMMAND publish l "Publish the current target"
CALL :DEFINECOMMAND run     r "Run the current target"
CALL :DEFINECOMMAND version v "Show version information"

CALL :DEFINECOMMANDCOMBINATION rebuild     cb  "Clean and Build"
CALL :DEFINECOMMANDCOMBINATION rebuildtest cbt "Clean, Build and Test"

GOTO :PARSE


:DEFINECOMMAND
SET /A DEFINEDCOMMANDCOUNT+=1

SET DEFINEDCOMMANDNAME%DEFINEDCOMMANDCOUNT%=%~1
SET DEFINEDCOMMANDALIAS%DEFINEDCOMMANDCOUNT%=%~2
SET DEFINEDCOMMANDDESCRIPTION%DEFINEDCOMMANDCOUNT%=%~3
GOTO :EOF

:DEFINECOMMANDCOMBINATION
SET /A DEFINECOMMANDCOMBINATIONCOUNT+=1

SET DEFINEDCOMMANDCOMBINATIONNAME%DEFINECOMMANDCOMBINATIONCOUNT%=%~1
SET DEFINEDCOMMANDCOMBINATIONALIAS%DEFINECOMMANDCOMBINATIONCOUNT%=%~2
SET DEFINEDCOMMANDCOMBINATIONDESCRIPTION%DEFINECOMMANDCOMBINATIONCOUNT%=%~3
GOTO :EOF


REM --------------------------------------------------------------------------------
:PARSE
IF /I "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?"  SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?"  SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X"  SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X"  SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z"  SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z"  SET DRYRUN=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/T"  SET TARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-T"  SET TARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/P"  SET PROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-P"  SET PROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/R"  SET PROFILE=release&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-R"  SET PROFILE=release&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/O"  SET OUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-O"  SET OUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/PO" SET PACKOUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-PO" SET PACKOUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/LP" SET LAUNCHPROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-LP" SET LAUNCHPROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/IR" SET INCOMPATIBLEREPORT=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-IR" SET INCOMPATIBLEREPORT=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/Q"  SET VERBOSITY=&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Q"  SET VERBOSITY=&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y"  SET VERBOSITY=v&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y"  SET VERBOSITY=v&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/YV" SET VERBOSITY=vv&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-YV" SET VERBOSITY=vv&&SHIFT&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/A"  SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-A"  SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1

CALL :PARSECOMMAND %~1
IF "%PARSECOMMANDSUCCESS%" == "Y" SHIFT&&GOTO :PARSE

CALL :USAGE
ECHO.
CALL :ERROR "%INTERNAL_ERROR%"
CALL :ERROR "Unexpected argument as pos %ARGPOS% : %~1"
GOTO :EOF


:VALIDATE
IF "%HELP%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

IF %COMMANDCOUNT% LSS 1 (
  CALL :USAGE
  ECHO.
  CALL :ERROR "No command specified."
  GOTO :EOF
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=@ECHO.

:GO
CALL :SHOWBANNER "Running %COMMANDCOUNT% commands [%COMMANDSDESCRIPTION%], for Profile %PROFILE% with verbosity: %VERBOSITY%"

FOR /L %%I IN (1, 1, %COMMANDCOUNT%) DO CALL :HANDLECOMMAND %%I
GOTO :EOF


REM --------------------------------------------------------------------------------
:USAGE

ECHO.%SCRIPTNAME% - cargo (rust) command helper
ECHO.Usage: %~n0 [command] [options]
ECHO.
ECHO.Commands:
FOR /L %%I IN (1,1, %DEFINEDCOMMANDCOUNT%) DO (
  SET CMDNAME=!DEFINEDCOMMANDNAME%%I!
  SET CMDALIAS=!DEFINEDCOMMANDALIAS%%I!
  SET CMDDESC=!DEFINEDCOMMANDDESCRIPTION%%I!

  REM ECHO.!CMDNAME!  - !CMDDESC! (Alias: !CMDALIAS!)
  PRINTFORMAT "{0,-14} - {1} (Alias: {2})" "!CMDNAME!" "!CMDDESC!" "!CMDALIAS!"
)
ECHO.
FOR /L %%I IN (1,1, %DEFINECOMMANDCOMBINATIONCOUNT%) DO (
  SET CMDNAME=!DEFINEDCOMMANDCOMBINATIONNAME%%I!
  SET CMDALIAS=!DEFINEDCOMMANDCOMBINATIONALIAS%%I!
  SET CMDDESC=!DEFINEDCOMMANDCOMBINATIONDESCRIPTION%%I!

  PRINTFORMAT "{0,-14} - {1} (Alias: {2})" "!CMDNAME!" "!CMDDESC!" "!CMDALIAS!"
)
ECHO.
ECHO.You can concatenate commands using the shortcuts, to execute those commands in sequence.
ECHO. E.g. 'csbtp' will execute 'clean', 'restore', 'build', 'test', and 'pack'.
ECHO.
ECHO.Options:
ECHO./P [profile]   - Set the build Profile (Default: %PROFILE%)
ECHO./A [arguments] - Add the arguments 
ECHO./Q             - Suppress output (Verbosity: quiet)
ECHO./Y             - Set the verbosity level to Verbose
ECHO./YV            - Set the Verbosity level to Very Verbose

GOTO :EOF


REM --------------------------------------------------------------------------------
:ERROR
ECHO.ERROR: %~1
GOTO :EOF


REM --------------------------------------------------------------------------------
:ADDCOMMAND
IF "%~1" == "" GOTO :EOF

SET /A COMMANDCOUNT+=1
SET COMMAND%COMMANDCOUNT%=%~1

IF "%COMMANDSDESCRIPTION%" == "" (
  SET COMMANDSDESCRIPTION=%~1
) ELSE (
  SET COMMANDSDESCRIPTION=%COMMANDSDESCRIPTION%, %~1
)

GOTO :EOF


REM --------------------------------------------------------------------------------
:PARSECOMMAND
SET INTERNAL_ERROR=
SET PARSECOMMANDSUCCESS=N
IF "%~1" == "" GOTO :EOF

SET PARSECOMMANDSUCCESS=Y
IF /I "%~1" == "clean"    CALL :ADDCOMMAND clean && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "restore"  CALL :ADDCOMMAND restore && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "build"    CALL :ADDCOMMAND build && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "test"     CALL :ADDCOMMAND test && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "pack"     CALL :ADDCOMMAND pack && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "publish"  CALL :ADDCOMMAND publish && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "run"      CALL :ADDCOMMAND run && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF
IF /I "%~1" == "version"  CALL :ADDCOMMAND version && SET PARSECOMMANDSUCCESS=Y&& GOTO :EOF

IF /I "%~1" == "rebuild" (
  CALL :ADDCOMMAND clean
  CALL :ADDCOMMAND build
  GOTO :EOF
)
if /I "%~1" == "rebuildtest" (
  CALL :ADDCOMMAND clean
  CALL :ADDCOMMAND build
  CALL :ADDCOMMAND test
  GOTO :EOF
)

SET COMMANDPARTS=%~1
:PARSECOMMANDLOOP
IF "%COMMANDPARTS%" == "" GOTO :EOF

SET COMMANDPART=%COMMANDPARTS:~0,1%

IF /I "%COMMANDPART%" == "c" (
  CALL :ADDCOMMAND clean
) ELSE IF /I "%COMMANDPART%" == "s" (
  CALL :ADDCOMMAND restore
) ELSE IF /I "%COMMANDPART%" == "b" (
  CALL :ADDCOMMAND build
) ELSE IF /I "%COMMANDPART%" == "t" (
  CALL :ADDCOMMAND test
) ELSE IF /I "%COMMANDPART%" == "p" (
  CALL :ADDCOMMAND pack
) ELSE IF /I "%COMMANDPART%" == "u" (
  CALL :ADDCOMMAND publish
) ELSE IF /I "%COMMANDPART%" == "r" (
  CALL :ADDCOMMAND run
) ELSE IF /I "%COMMANDPART%" == "v" (
  CALL :ADDCOMMAND version
) ELSE (
  SET PARSECOMMANDSUCCESS=N
  SET INTERNAL_ERROR=Invalid command shortcut '%COMMANDPART%' in '%~1'
  GOTO :EOF
)

SET COMMANDPARTS=%COMMANDPARTS:~1%

GOTO :PARSECOMMANDLOOP


REM --------------------------------------------------------------------------------
:HANDLECOMMAND
SET COMMAND=!COMMAND%~1!

IF /I "%COMMAND%" == "clean"    CALL :COMMAND_CLEAN   && GOTO :EOF
IF /I "%COMMAND%" == "restore"  CALL :COMMAND_RESTORE && GOTO :EOF
IF /I "%COMMAND%" == "build"    CALL :COMMAND_BUILD   && GOTO :EOF
IF /I "%COMMAND%" == "test"     CALL :COMMAND_TEST    && GOTO :EOF
IF /I "%COMMAND%" == "check"    CALL :COMMAND_CHECK    && GOTO :EOF
IF /I "%COMMAND%" == "publish"  CALL :COMMAND_PUBLISH && GOTO :EOF
IF /I "%COMMAND%" == "run"      CALL :COMMAND_RUN     && GOTO :EOF
IF /I "%COMMAND%" == "version"  CALL :COMMAND_VERSION && GOTO :EOF

CALL :ERROR "Invalid or Unknown command : %COMMAND%"
GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_CLEAN
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%
IF NOT "%PROFILE%" == ""           SET EXTRA=%EXTRA% --profile %PROFILE%

CALL :SHOWCOMMANDBANNER "clean"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo clean %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_RESTORE
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%

CALL :SHOWCOMMANDBANNER "restore"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo restore %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_BUILD

IF "%TARGET%" == "" SET TARGET=--all-targets

SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%
IF NOT "%PROFILE%" == ""           SET EXTRA=%EXTRA% --profile %PROFILE%
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% --target=dir %OUTPUTDIR%
IF "%INCOMPATIBLEREPORT%" == "Y"   SET EXTRA=%EXTRA% --future-incompat-report

CALL :SHOWCOMMANDBANNER "build"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo build %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_TEST

IF "%TARGET%" == "" SET TARGET=--all-targets

SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%
IF NOT "%PROFILE%" == ""           SET EXTRA=%EXTRA% --profile %PROFILE%
IF "%INCOMPATIBLEREPORT%" == "Y"   SET EXTRA=%EXTRA% --future-incompat-report

CALL :SHOWCOMMANDBANNER "test"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo test %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_PUBLISH
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%
IF NOT "%PROFILE%" == ""           SET EXTRA=%EXTRA% --profile %PROFILE%
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% --target=dir %OUTPUTDIR%

CALL :SHOWCOMMANDBANNER "publish"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo publish %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_RUN
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -%VERBOSITY%
IF NOT "%PROFILE%" == ""           SET EXTRA=%EXTRA% --profile %PROFILE%
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% --target=dir %OUTPUTDIR%
IF NOT "%APPARGS%" == ""           SET EXTRA=%EXTRA% -- %APPARGS%

CALL :SHOWCOMMANDBANNER "run %APPARGS%"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo run %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_VERSION
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%cargo --version
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:SHOWBANNER
IF "%~1" == "" GOTO :EOF

ECHO.
BANNERTEXT "%~1" @%SCRIPTPATH%\%SCRIPTNAME%.bannertext.options

GOTO :EOF


REM --------------------------------------------------------------------------------
:SHOWCOMMANDBANNER
IF "%~1" == "" GOTO :EOF

ECHO.
BANNERTEXT "%~1" @%SCRIPTPATH%\%SCRIPTNAME%.bannertext.options -hlc "-" -tlc "-"

GOTO :EOF


REM --------------------------------------------------------------------------------
:UpCase
:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF
