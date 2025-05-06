@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.dacpac

SET DEBUG=N
SET SERVER=
SET USER=
SET PASS=
SET AD=N
SET TABLEDATA=True
SET APPSCOPEDOBJECTS=True
SET REFSCOPEDELEMENTS=False
SET OPTS=

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
IF /I "%~1" == "-ad" (
    SET AD=Y
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-td" (
    SET TABLEDATA=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-as" (
    SET APPSCOPEDOBJECTS=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-rs" (
    SET REFSCOPEDELEMENTS=%~2
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

IF "%AD%" == "Y" (
    SET OPTS=%OPTS% /UniversalAuthentication:True
    SET SQLAUTH=
)

ECHO.Extracting %DATABASE% from %SERVER%
@IF "%DEBUG%" == "Y" ECHO ON
"%SQLPACKAGE_EXE%" /action:extract /scs:"Server=%SERVER%;Database=%DATABASE%;%SQLAUTH%" /tf:%FILENAME% /p:"ExtractAllTableData=%TABLEDATA%" /p:"ExtractApplicationScopedObjectsOnly=%APPSCOPEDOBJECTS%" /p:"ExtractReferencedServerScopedElements=%REFSCOPEDELEMENTS%" %OPTS%
@IF "%DEBUG%" == "Y" ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Extract a single Database schema from a server to a %BACKUPEXTENSION% file, optionally with data
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [database-name] [options]
ECHO.
ECHO.Options:
ECHO. -f [filename:database-name[%BACKUPEXTENSION%]]
ECHO. -s [server-name:%SERVER%]
ECHO. -u [sql-username]
ECHO. -p [sql-password]
ECHO. -ad                                       (Connect via AD / MFA Auth)
ECHO. -td [table-data:%TABLEDATA%]
ECHO. -as [application-scoped-objects:%APPSCOPEDOBJECTS%]
ECHO. -rs [extract-referenced-server-scoped-elements:%REFSCOPEDELEMENTS%]
ECHO. -x                                        (Debug : show executed commands)
ECHO.
ECHO.NOTE: If sql-username is empty, a trusted connection is assumed

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
