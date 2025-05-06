@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET BACKUPEXTENSION=.bacpac

SET IMPORTCMD=%SCRIPTPATH%\SQLImportDb.cmd

SET FOLDER=.
SET SERVER=
SET USER=
SET PASS=
SET EDITION=Default

IF "%SQLCMD_EXE%" == "" SET SQLCMD_EXE=SQLCMD.EXE
IF "%SQLPACKAGE_EXE%" == "" SET SQLPACKAGE_EXE=SQLPACKAGE.EXE

:PARSEARGS
IF /I "%~1" == "-f" (
    SET FOLDER=%~2
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
IF /I "%~1" == "-e" (
    SET EDITION=%~2
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

IF NOT EXIST "%FOLDER%\*%BACKUPEXTENSION%" (
    CALL :ERROR No files found : %FOLDER%\*%BACKUPEXTENSION%
    GOTO :EOF
)

FOR %%F IN (%FOLDER%\*%BACKUPEXTENSION%) DO (
    ECHO.
    ECHO.Importing: [%%~F]
    CALL "%IMPORTCMD%" "%%~F" -S "%SERVER%" -U "%USER%" -P "%PASS%" -e "%EDITION%"
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Import all %BACKUPEXTENSION% files in a folder into Databases on a server
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [options]
ECHO.
ECHO.Options:
ECHO. -f [folder-name:%FOLDER%]
ECHO. -s [server-name:%SERVER%]
ECHO. -u [sql-username]
ECHO. -p [sql-password]
ECHO. -e [database-edition:%EDITION%]
ECHO. -x (Debug : show executed commands)
ECHO.
ECHO.NOTE: If sql-username is empty, a trusted connection is assumed

GOTO :EOF


:ERROR
ECHO.Error: %*

GOTO :EOF
