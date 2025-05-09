@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET POS=0
SET DEBUG=N
SET DRYRUN=N
SET EXTENSION=
SET DIRECTORY=
SET REQUESTEDINDEX=N
SET INDEX=0
SET ALLOWONLYONE=N
SET DEBUG=N

SET FILEINDEX=0

:PARSEOPTIONS
IF /I "%~1" == "/x" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-x" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/z" SET DRYRUN=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-z" SET DRYRUN=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/d" SET DIRECTORY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-d" SET DIRECTORY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/f" SET DIRECTORY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-f" SET DIRECTORY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/i" SET REQUESTEDINDEX=Y&& SET INDEX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-i" SET REQUESTEDINDEX=Y&& SET INDEX=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/o" SET ALLOWONLYONE=Y&& SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-o" SET ALLOWONLYONE=Y&& SHIFT && GOTO :PARSEOPTIONS

SET /A POS+=1
IF NOT "%~1" == "" (
  IF %POS% EQU 1 SET EXTENSION=%~1
  
  SHIFT
  GOTO :PARSEOPTIONS
)

:VALIDATE
IF "%EXTENSION%" == "" (
  CALL :USAGE
  CALL :ERROR No extension supplied
  GOTO :EOF
)
IF "%REQUESTEDINDEX%" == "Y" (
  IF %INDEX% LEQ 0 (
    CALL :USAGE
    CALL :ERROR Invalid requested Index : %INDEX%
    GOTO :EOF
  )
)

:FINDFILES
IF NOT "%DIRECTORY%" == "" PUSHD "%DIRECTORY%"

@IF "%DEBUG%" == "Y" @ECHO ON
FOR %%F IN (*.%EXTENSION%) DO CALL :FOUNDFILE %%~F
IF %FILEINDEX% GTR 0 GOTO :VERIFYFOUNDFILES
FOR %%F IN (*%EXTENSION%) DO CALL :FOUNDFILE %%~F
IF %FILEINDEX% GTR 0 GOTO :VERIFYFOUNDFILES
FOR %%F IN (%EXTENSION%) DO CALL :FOUNDFILE %%~F
@IF "%DEBUG%" == "Y" @ECHO OFF

:VERIFYFOUNDFILES
IF %FILEINDEX% GTR 1 (
  ECHO.Found %FILEINDEX% files
)

IF "%ALLOWONLYONE%" == "Y" (
  IF %INDEX% EQU 0 (
    IF %FILEINDEX% GTR 1 (
      CALL :ERROR Only allowed to find 1 file
      GOTO :EOF
    )
  )
)

:FINDFILEMATCH
SET FILENAME=
@IF "%DEBUG%" == "Y" ECHO ON
IF %INDEX% GTR 0 (
  SET FILENAME=!FILENAME%INDEX%!
) ELSE (
  SET FILENAME=%FILENAME1%
)
@IF "%DEBUG%" == "Y" @ECHO OFF

IF "%FILENAME%" == "" (
  IF %INDEX% GTR 0 (
    CALL :ERROR No File found at Index: %INDEX% for extension: %EXTENSION%
  ) ELSE (
    CALL :ERROR No File found for extension: %EXTENSION%
  )
  GOTO :EOF
)

:EXECUTE
SET EXECPREFIX=
IF "%DRYRUN%" == "Y" SET EXECPREFIX=ECHO.

@IF "%DEBUG%" == "Y" ECHO ON
%EXECPREFIX%CALL "%SCRIPTPATH%\EXEC.CMD" "%FILENAME%"
@IF "%DEBUG%" == "Y" @ECHO OFF

IF NOT "%DIRECTORY%" == "" POPD

GOTO :EOF


:FOUNDFILE
IF NOT EXIST "%~1" GOTO :EOF

SET /A FILEINDEX+=1
IF "%DEBUG%" == "Y" ECHO.DEBUG: Adding File %FILEINDEX% - %~1
SET FILENAME%FILEINDEX%=%~1
GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Execute a file in a directory, based on File Extension
ECHO.
ECHO.Usage:
ECHO.%SCRIPTNAME% [Extension] { [options] }
ECHO.
ECHO.Extension can be flexible:
ECHO. txt, .txt, *.txt  - Would all find .txt files
ECHO.
ECHO.Options: [/-] prefix supported
ECHO. /x        - Turn on Debugging
ECHO. /z        - Dry Run - do NOT execute found file (Default: %DRYRUN%)
ECHO. /d [dir]  - Specify the Directory
ECHO. /f [dir]  - Specify the Directory
ECHO. /i [num]  - Specify the File Index to use [1..n] (Default: %INDEX%)
ECHO. /o        - Allow only 1 Found File (Default: %ALLOWONLYONE%)
ECHO.

GOTO :EOF


:ERROR
ECHO.ERROR: %*
GOTO :EOF
