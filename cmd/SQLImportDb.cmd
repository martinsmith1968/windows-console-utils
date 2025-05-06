@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.bacpac

SET DEBUG=N
SET SERVER=localhost
SET USER=
SET PASS=
SET AD=N
SET EDITION=Default
SET STORAGE=Memory
SET OPTS=

IF "%SQLCMD_EXE%" == "" SET SQLCMD_EXE=SQLCMD.EXE
IF "%SQLPACKAGE_EXE%" == "" SET SQLPACKAGE_EXE=SQLPACKAGE.EXE

SET FILENAME=%~1
SET DEFAULT_DATABASE=%~n1

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
IF /I "%~1" == "-e" (
    SET EDITION=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)
IF /I "%~1" == "-st" (
    SET STORAGE=%~2
    SHIFT
    SHIFT
    GOTO :PARSEARGS
)

IF NOT "%~1" == "" (
    SHIFT
    GOTO :PARSEARGS
)

IF "%FILENAME%" == "" (
    CALL :USAGE
    GOTO :EOF
)

IF NOT EXIST "%FILENAME%" (
    CALL :USAGE
    CALL :ERROR "File not found: %FILENAME%"
    GOTO :EOF
)

IF "%DATABASE%" == "" SET DATABASE=%DEFAULT_DATABASE%

SET SQLAUTH=Trusted_Connection=True
SET SQLCMDAUTH=-E
IF NOT "%USER%" == "" (
    SET SQLAUTH=Trusted_Connection=False;User ID=%USER%;Password=%PASS%
    SET SQLCMDAUTH=-U %USER% -P %PASS%
)

ECHO.Dropping: %DATABASE% on %SERVER%...
@IF "%DEBUG%" == "Y" ECHO ON
"%SQLCMD_EXE%" %SQLCMDAUTH% -S "%SERVER%" -d master -Q "IF DB_ID('%DATABASE%') IS NOT NULL BEGIN; ALTER DATABASE [%DATABASE%] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [%DATABASE%]; END;"
@IF "%DEBUG%" == "Y" ECHO OFF

ECHO.Importing %DATABASE% from %FILENAME%
@IF "%DEBUG%" == "Y" ECHO ON
"%SQLPACKAGE_EXE%" /action:import /sf:"%FILENAME%" /tcs:"Server=%SERVER%;Database=%DATABASE%;%SQLAUTH%;" /p:Storage=%STORAGE% /p:DatabaseEdition=%EDITION%
@IF "%DEBUG%" == "Y" ECHO OFF

ECHO.Creating Login...
@IF "%DEBUG%" == "Y" ECHO ON
"%SQLCMD_EXE%" %SQLCMDAUTH% -S "%SERVER%" -d "%DATABASE%" -Q "IF NOT EXISTS(SELECT * FROM sys.database_principals where [name]='NT AUTHORITY\NETWORK SERVICE') BEGIN; CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]; END;"
@IF "%DEBUG%" == "Y" ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Import a single %BACKUPEXTENSION% file into a Database on a server
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [filename] [options]
ECHO.
ECHO.Options:
ECHO. -d  [database-name:filename[%BACKUPEXTENSION%]]
ECHO. -s  [server-name:%SERVER%]
ECHO. -u  [sql-username]
ECHO. -p  [sql-password]
ECHO. -e  [database-edition:%EDITION%]
ECHO. -st [storage-type:%STORAGE%]
ECHO. -x  (Debug : show executed commands)
ECHO.
ECHO.NOTE: If sql-username is empty, a trusted connection is assumed

IF EXIST "*%BACKUPEXTENSION%" (
    ECHO.
    ECHO.Databases:
    DIR /B *%BACKUPEXTENSION%
)

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
