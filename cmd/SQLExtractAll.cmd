@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.dacpac

SET EXTRACTCMD=%SCRIPTPATH%\SQLExtractDb.cmd

SET DEBUG=N
SET SERVER=
SET USER=
SET PASS=
SET FOLDER=
SET IGNOREDBS=
SET TABLEDATA=True
SET APPSCOPEDOBJECTS=True
SET REFSCOPEDELEMENTS=False

IF "%SQLCMD_EXE%" == "" SET SQLCMD_EXE=SQLCMD.EXE
IF "%SQLPACKAGE_EXE%" == "" SET SQLPACKAGE_EXE=SQLPACKAGE.EXE

:PARSEARGS
IF /I "%~1" == "-x" (
    SET DEBUG=Y
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
IF /I "%~1" == "-f" (
    SET FOLDER=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-i" (
    SET IGNOREDBS=%~2
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

SET SQLAUTH=-E
IF NOT "%USER%" == "" SET SQLAUTH=-U %USER% -P %PASS%

SET EXTRA=
IF "%DEBUG%" == "Y" SET EXTRA=%EXTRA% -x

SET IGNOREFILTER=
IF NOT "%IGNOREDBS%" == "" (
    SET IGNOREFILTER=AND ',%IGNOREDBS%,' NOT LIKE CONCAT^('^%,',[name],',^%'^)
)

IF NOT "%FOLDER%" == "" (
    IF NOT EXIST "%FOLDER%\*.*" (
        MKDIR "%FOLDER%" >NUL
    )
    PUSHD "%FOLDER%"
)

ECHO.Querying %SERVER%
FOR /F "usebackq tokens=1-2" %%F IN (`%SQLCMD_EXE% -S "%SERVER%" %SQLAUTH% -d master -Q "SET NOCOUNT ON; SELECT [name] FROM sys.databases WHERE owner_sid != 1 AND [name] != 'master' %IGNOREFILTER% ORDER BY [name]" -h -1`) DO (
    ECHO.
    ECHO.Extracting: [%%~F]
    CALL "%EXTRACTCMD%" "%%~F" -s %SERVER% %SQLAUTH% -td %TABLEDATA% -as %APPSCOPEDOBJECTS% -rs %REFSCOPEDELEMENTS% %EXTRA%
)

IF NOT "%FOLDER%" == "" (
    POPD
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Extract all Database schemas from a server to %BACKUPEXTENSION% files, optionally with data
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [options]
ECHO.
ECHO.Options:
ECHO. -f [output-folder:%FOLDER%]
ECHO. -s [server-name:%SERVER%]
ECHO. -u [sql-username]
ECHO. -p [sql-password]
ECHO. -i [ignore-databases] (Comma separated list of databases to be ignored)
ECHO. -td [table-data:%TABLEDATA%]
ECHO. -as [application-scoped-objects:%APPSCOPEDOBJECTS%]
ECHO. -rs [referenced-server-scoped-elements:%REFSCOPEDELEMENTS%]
ECHO. -x (Debug : show executed commands)
ECHO.
ECHO.NOTE: If sql-username is empty, a trusted connection is assumed

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
