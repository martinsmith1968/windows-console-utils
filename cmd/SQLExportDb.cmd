@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.bacpac

SET DEBUG=N
SET SERVER=
SET USER=
SET PASS=
SET TARGETVERSION=Latest
SET VERIFY=True

IF "%SQLCMD_EXE%" == "" SET SQLCMD_EXE=SQLCMD.EXE
IF "%SQLPACKAGE_EXE%" == "" SET SQLPACKAGE_EXE=SQLPACKAGE.EXE

SET DATABASE=%~1

:PARSEARGS
IF /I "%~1" == "-x" (
    SET DEBUG=Y
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-f" (
    SET FILENAME=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-s" (
    SET SERVER=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-u" (
    SET USER=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-p" (
    SET PASS=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-t" (
    SET TARGETVERSION=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-v" (
    SET VERIFY=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)

IF NOT "%~1" == "" (
    SHIFT
    GOTO :PARSEARGS
)

IF "%SERVER%" == "" (
    CALL :USAGE
    GOTO :EOF
)
IF "%DATABASE%" == "" (
    CALL :USAGE
    GOTO :EOF
)

IF "%FILENAME%" == "" SET FILENAME=%DATABASE%%BACKUPEXTENSION%

SET SQLAUTH=Trusted_Connection=True
IF NOT "%USER%" == "" SET SQLAUTH=Trusted_Connection=False;User ID=%USER%;Password=%PASS%

ECHO.Exporting %DATABASE% from %SERVER%
@IF "%DEBUG%" == "Y" ECHO ON
"%SQLPACKAGE_EXE%" /action:export /scs:"Server=%SERVER%;Database=%DATABASE%;%SQLAUTH%" /tf:%FILENAME% /p:"TargetEngineVersion=%TARGETVERSION%" /p:"VerifyFullTextDocumentTypesSupported=%VERIFY%"
@IF "%DEBUG%" == "Y" ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Export a single Database from a server to a %BACKUPEXTENSION% file
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [database-name(s)] [options]
ECHO.
ECHO.Options:
ECHO. -f [filename:database-name%BACKUPEXTENSION%]
ECHO. -s [server-name:%SERVER%]
ECHO. -u [sql-username]
ECHO. -p [sql-password]
ECHO. -t [target-version:%TARGETVERSION%]
ECHO. -v [verify:%VERIFY%]
ECHO. -x (Debug : show executed commands)
ECHO.
ECHO.NOTE: If sql-username is empty, a trusted connection is assumed

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
