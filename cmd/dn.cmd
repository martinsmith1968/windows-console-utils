@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET DRYRUN=N
SET HELP=N
SET ARGPOS=0
SET COMMANDPREFIX=

SET VERBOSITY=normal
SET TARGET=
SET CONFIGURATION=
SET ARCHITECTURE=
SET OSPLATFORM=
SET VERSION=
SET VERSIONSUFFIX=
SET FRAMEWORK=
SET RUNTIMEIDENTIFIER=
SET OUTPUTDIR=
SET ISSELFCONTAINED=N
SET NOBUILD=N
SET NORESTORE=N
SET LAUNCHPROFILE=
SET APPARGS=

SET COMMANDCOUNT=0
SET COMMANDSDESCRIPTION=

REM Commands:
REM
REM c - clean
REM r - restore
REM b - build
REM p - pack
REM t - test
REM l - publish
REM r - run
REM v - version

REM --------------------------------------------------------------------------------
:PARSE
IF /I "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/T" SET TARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-T" SET TARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/C" SET CONFIGURATION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-C" SET CONFIGURATION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/A" SET ARCHITECTURE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-A" SET ARCHITECTURE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/OS" SET OSPLATFORM=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-OS" SET OSPLATFORM=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V" SET VERSION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VERSION=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/U" SET VERSIONSUFFIX=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-U" SET VERSIONSUFFIX=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/F" SET FRAMEWORK=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-F" SET FRAMEWORK=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/R" SET RUNTIMEIDENTIFIER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-R" SET RUNTIMEIDENTIFIER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/SC" SET ISSELFCONTAINED=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-SC" SET ISSELFCONTAINED=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/NB" SET NOBUILD=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-NB" SET NOBUILD=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/NR" SET NORESTORE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-NR" SET NORESTORE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/O" SET OUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-O" SET OUTPUTDIR=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/LP" SET LAUNCHPROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-LP" SET LAUNCHPROFILE=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/Q" SET VERBOSITY=quiet&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Q" SET VERBOSITY=quiet&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y" SET VERBOSITY=%~2&&SHIFT%&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y" SET VERBOSITY=%~2&&SHIFT%&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y0" SET VERBOSITY=quiet&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y0" SET VERBOSITY=quiet&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y1" SET VERBOSITY=minimal&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y1" SET VERBOSITY=minimal&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y2" SET VERBOSITY=normal&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y2" SET VERBOSITY=normal&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y3" SET VERBOSITY=detailed&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y3" SET VERBOSITY=detailed&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Y4" SET VERBOSITY=diagnostic&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Y4" SET VERBOSITY=diagnostic&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/A" SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-A" SET APPARGS=%APPARGS% %~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1

CALL :PARSECOMMAND %~1
IF "%PARSECOMMANDSUCCESS%" == "Y" SHIFT&&GOTO :PARSE

IF "%HELP%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

CALL :USAGE
CALL :ERROR "Unexpected argument as pos %ARGPOS% : %~1"
GOTO :EOF


:VALIDATE
IF %COMMANDCOUNT% LSS 1 (
  CALL :USAGE
  GOTO :EOF
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=@ECHO.

:GO
CALL :SHOWBANNER "Running %COMMANDCOUNT% commands [%COMMANDSDESCRIPTION%] with verbosity %VERBOSITY%"

FOR /L %%I IN (1, 1, %COMMANDCOUNT%) DO CALL :HANDLECOMMAND %%I
GOTO :EOF


REM --------------------------------------------------------------------------------
:USAGE
ECHO.%SCRIPTNAME% - dotnet command helper
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
ECHO./Q                 - Suppress output (Verbosity: quiet)
ECHo./Y [verbosity]     - Set the verbosity level (default: minimal) (q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic])
ECHO./Y0[-4]            - Set the Verbosity level (0=quiet, 1=minimal, 2=normal, 3=detailed, 4=diagnostic)

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
SET PARSECOMMANDSUCCESS=N

IF /I "%~1" == "clean"   CALL :ADDCOMMAND clean&& GOTO :EOF
IF /I "%~1" == "restore" CALL :ADDCOMMAND restore&& GOTO :EOF
IF /I "%~1" == "build"   CALL :ADDCOMMAND build&& GOTO :EOF
IF /I "%~1" == "pack"    CALL :ADDCOMMAND pack&& GOTO :EOF
IF /I "%~1" == "test"    CALL :ADDCOMMAND test&& GOTO :EOF

IF /I "%~1" == "rebuild" (
  CALL :ADDCOMMAND clean
  CALL :ADDCOMMAND build
  GOTO :EOF
)

SET COMMANDPARTS=%~1
:PARSECOMMANDLOOP
IF "%COMMANDPARTS%" == "" (
  SET PARSECOMMANDSUCCESS=Y
  GOTO :EOF
)

SET COMMANDPART=%COMMANDPARTS:~0,1%

IF /I "%COMMANDPART%" == "c" (
  CALL :ADDCOMMAND clean
) ELSE IF /I "%COMMANDPART%" == "r" (
  CALL :ADDCOMMAND restore
) ELSE IF /I "%COMMANDPART%" == "b" (
  CALL :ADDCOMMAND build
) ELSE IF /I "%COMMANDPART%" == "p" (
  CALL :ADDCOMMAND pack
) ELSE IF /I "%COMMANDPART%" == "t" (
  CALL :ADDCOMMAND test
) ELSE (
  CALL :ERROR "Invalid command alias/abbreviation: %COMMANDPART%"
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
IF /I "%COMMAND%" == "pack"     CALL :COMMAND_PACK    && GOTO :EOF
IF /I "%COMMAND%" == "test"     CALL :COMMAND_TEST    && GOTO :EOF
IF /I "%COMMAND%" == "publish"  CALL :COMMAND_PUBLISH && GOTO :EOF
IF /I "%COMMAND%" == "run"      CALL :COMMAND_RUN     && GOTO :EOF
IF /I "%COMMAND%" == "version"  CALL :COMMAND_VERSION && GOTO :EOF

CALL :ERROR "Invalid or Unknown command : %COMMAND%"
GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_CLEAN
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF NOT "%FRAMEWORK%" == ""         SET EXTRA=%EXTRA% -f %FRAMEWORK%
IF NOT "%RUNTIMEIDENTIFIER%" == "" SET EXTRA=%EXTRA% -r %RUNTIMEIDENTIFIER%
IF NOT "%ARCHITECTURE%" == ""      SET EXTRA=%EXTRA% -a %ARCHITECTURE%
IF NOT "%OSPLATFORM%" == ""        SET EXTRA=%EXTRA% -os %OSPLATFORM%
REM NOTE: OUTPUTDIR is not implemented for clean command (but IS supported)

CALL :SHOWCOMMANDBANNER "clean"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet clean %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_RESTORE
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%

CALL :SHOWCOMMANDBANNER "restore"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet restore %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_BUILD
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF NOT "%FRAMEWORK%" == ""         SET EXTRA=%EXTRA% -f %FRAMEWORK%
IF NOT "%RUNTIMEIDENTIFIER%" == "" SET EXTRA=%EXTRA% -r %RUNTIMEIDENTIFIER%
IF "%ISSELFCONTAINED%" == "Y"      SET EXTRA=%EXTRA% --self-contained
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% -o %OUTPUTDIR%
IF NOT "%VERSIONSUFFIX%" == ""     SET EXTRA=%EXTRA% --version-suffix %VERSIONSUFFIX%
IF NOT "%VERSION%" == ""           SET EXTRA=%EXTRA% /p:Version=%VERSION%

CALL :SHOWCOMMANDBANNER "build"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet build %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_PACK
SET PACKAGEVERSION=%VERSION%
IF NOT "%VERSIONSUFFIX%" == "" (
  IF NOT "%VERSION%" == "" (
    SET PACKAGEVERSION=%VERSION%-%VERSIONSUFFIX%
  ) ELSE (
    SET PACKAGEVERSION=%VERSIONSUFFIX%
  )
)

SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF "%NOBUILD%" == "Y"              SET EXTRA=%EXTRA% --no-build
IF "%NORESTORE%" == "Y"            SET EXTRA=%EXTRA% --no-restore
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% -o %OUTPUTDIR%
IF NOT "%VERSIONSUFFIX%" == ""     SET EXTRA=%EXTRA% --version-suffix %VERSIONSUFFIX%
IF NOT "%VERSION%" == ""           SET EXTRA=%EXTRA% /p:Version=%PACKAGEVERSION%

CALL :SHOWCOMMANDBANNER "pack"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet pack %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_TEST
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF NOT "%FRAMEWORK%" == ""         SET EXTRA=%EXTRA% -f %FRAMEWORK%
IF NOT "%RUNTIMEIDENTIFIER%" == "" SET EXTRA=%EXTRA% -r %RUNTIMEIDENTIFIER%
IF "%NOBUILD%" == "Y"              SET EXTRA=%EXTRA% --no-build
IF "%NORESTORE%" == "Y"            SET EXTRA=%EXTRA% --no-restore

CALL :SHOWCOMMANDBANNER "test"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet test %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_PUBLISH
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF NOT "%FRAMEWORK%" == ""         SET EXTRA=%EXTRA% -f %FRAMEWORK%
IF NOT "%RUNTIMEIDENTIFIER%" == "" SET EXTRA=%EXTRA% -r %RUNTIMEIDENTIFIER%
IF "%ISSELFCONTAINED%" == "Y"      SET EXTRA=%EXTRA% --self-contained
IF NOT "%OUTPUTDIR%" == ""         SET EXTRA=%EXTRA% -o %OUTPUTDIR%
IF NOT "%VERSIONSUFFIX%" == ""     SET EXTRA=%EXTRA% --version-suffix %VERSIONSUFFIX%
IF NOT "%VERSION%" == ""           SET EXTRA=%EXTRA% /p:Version=%VERSION%
IF "%NOBUILD%" == "Y"              SET EXTRA=%EXTRA% --no-build
IF "%NORESTORE%" == "Y"            SET EXTRA=%EXTRA% --no-restore

CALL :SHOWCOMMANDBANNER "test"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet publish %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_RUN
SET EXTRA=
IF NOT "%TARGET%" == ""            SET EXTRA=%EXTRA% %TARGET%
IF NOT "%VERBOSITY%" == ""         SET EXTRA=%EXTRA% -v %VERBOSITY%
IF NOT "%CONFIGURATION%" == ""     SET EXTRA=%EXTRA% -c %CONFIGURATION%
IF NOT "%FRAMEWORK%" == ""         SET EXTRA=%EXTRA% -f %FRAMEWORK%
IF NOT "%RUNTIMEIDENTIFIER%" == "" SET EXTRA=%EXTRA% -r %RUNTIMEIDENTIFIER%
IF "%ISSELFCONTAINED%" == "Y"      SET EXTRA=%EXTRA% --self-contained
IF "%NOBUILD%" == "Y"              SET EXTRA=%EXTRA% --no-build
IF "%NORESTORE%" == "Y"            SET EXTRA=%EXTRA% --no-restore
IF NOT "%LAUNCHPROFILE%" == ""     SET EXTRA=%EXTRA% -lp %LAUNCHPROFILE%
IF "%LAUNCHPROFILE%" == ""         SET EXTRA=%EXTRA% --no-launch-profile
IF NOT "%APPARGS%" == ""           SET EXTRA=%EXTRA% -- %APPARGS%

CALL :SHOWCOMMANDBANNER "run %APPARGS%"
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%dotnet run %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:COMMAND_VERSION
SET APP=%SCRIPTPATH%\..\win\dotnetver.exe

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%START "" "%APP%"
%COMMANDPREFIX%dotnet --info
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


REM --------------------------------------------------------------------------------
:SHOWBANNER
IF "%~1" == "" GOTO :EOF

BANNERTEXT "%~1" @%SCRIPTPATH%\%SCRIPTNAME%.bannertext.options -fln 1

GOTO :EOF


REM --------------------------------------------------------------------------------
:SHOWCOMMANDBANNER
IF "%~1" == "" GOTO :EOF

ECHO.
BANNERTEXT "%~1" @%SCRIPTPATH%\%SCRIPTNAME%.bannertext.options

GOTO :EOF


REM --------------------------------------------------------------------------------
:UpCase
:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF
