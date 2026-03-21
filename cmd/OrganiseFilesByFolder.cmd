@ECHO OFF

SETLOCAL EnableDelayedExpansion

REM ********************************************************************************
REM ** DESCRIPTION: Move files from one folder to target folders based on wildcards
REM **
REM ** Needs GnuUtils installed in order to work:
REM ** - SED
REM ** - WC
REM ********************************************************************************

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET ARGPOS=
SET HELP=N
SET DEBUG=N
SET DRYRUN=N
SET VERBOSE=Y
SET FOLDER=
SET EXTENSION=*
SET TARGET=
SET SUFFIX=


:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?"  SET HELP=Y&& GOTO :EOF
IF /I "%~1" == "-?"  SET HELP=Y&& GOTO :EOF
IF /I "%~1" == "/X"  SET DEBUG=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-X"  SET DEBUG=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/Z"  SET DRYRUN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-Z"  SET DRYRUN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/F"  SET FOLDER=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-F"  SET FOLDER=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/E"  SET EXTENSION=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-E"  SET EXTENSION=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/T"  SET TARGET=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-T"  SET TARGET=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/S"  SET SUFFIX=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-S"  SET SUFFIX=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/V"  SET VERBOSE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-V"  SET VERBOSE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/V-" SET VERBOSE=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-V-" SET VERBOSE=N&& SHIFT && GOTO :PARSE

SET /A ARGPOS+=1

CALL :USAGE
CALL :ERROR "Invalid argument at position: %ARGPOS% : %~1%"
GOTO :EOF


:VALIDATE
IF "%FOLDER%" == "" (
  CALL :USAGE
  CALL :ERROR "FOLDER not specified"
)

IF "%TARGET%" == "" SET TARGET=%FOLDER%


:GO
SET WILDCARD=%SUFFIX%*.%EXTENSION%

IF "%VERBOSE%" == "Y" (
    ECHO.Searching : %FOLDER%
    ECHO.For files : [folder-name]%WILDCARD%
    ECHO.Moving to : %TARGET%
)
ECHO.


CALL "BuildUniqueTempFileName.cmd" "%SCRIPTNAME%"
IF "%DEBUG%" == "Y" ECHO.Using: %UNIQUETEMPFILENAME%
IF "%UNIQUETEMPFILENAME%" == "" (
  CALL :ERROR: "Unable to generate Unique Temp File Name"
  GOTO :EOF
)

PUSHD "%TARGET%"

DIR /ad /b /ogen > "%UNIQUETEMPFILENAME%"
FOR /F "tokens=*" %%F IN (%UNIQUETEMPFILENAME%) DO CALL :PROCESS "%%~F"

ECHO.
DIR %FOLDER%\*.%EXTENSION% /b 2>NUL | wc -l | SED -e "s/$/ files remaining/g"

POPD

GOTO :EOF


:PROCESS
ECHO.Processing Folder: %~1

IF NOT EXIST "%FOLDER%\%~1%WILDCARD%" (
  IF "%VERBOSE%" == "N" ECHO.  No Files found
  GOTO :EOF
)

SET FILECOUNT=0
CALL "%SCRIPTPATH%\CountFiles.cmd" "%FOLDER%" "%~1%WILDCARD%"

IF "%VERBOSE%" == "Y" (
   ECHO.  %FILECOUNT% files found
)

SET COMMADNRPREFIX=
SET COMMANDSUFFIX=
IF "%DRYRUN%" == "Y" (
   SET COMMANDPREFIX=@ECHO.
) ELSE (
   SET COMMANDSUFFIX=^> NUL
)

@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%MOVE "%FOLDER%\%~1%WILDCARD%" "%TARGET%\%~1" %COMMANDSUFFIX%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Organise Files ainto existing Folders
ECHO.
ECHO.Usage: %~n0 [options]
ECHO.
ECHO.Options:
ECHO./F     - Directory to find files in
ECHO./E     - The Extention to use for searching for files (Default: %EXTENSION%)
ECHO./T     - Target Directory to find matching folders in
ECHO./S     - The filename folder suffix to use to select files
ECHO./V[-]  - Verbose Mode (Default: %VERBOSE%)
ECHO./X     - Debug Mode (Default: %DEBUG%)
ECHO./Z     - Dry Run Mode (Default: %DRYRUN%)
ECHO./?     - Show Help

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
