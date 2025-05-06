@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET POS=1

SET DEBUG=N
SET USAGE=N
SET FOLDER=.
SET RECURSECHILDREN=N
SET MASTERBRANCH=master
SET SHOWONMASTER=N
SET UPDATEONMASTER=N
SET SHOWOUTOFDATE=N
SET SHOWWIP=N
SET SHOWNOTES=N
SET NOTESFILE=
SET OUTPUTTYPE=TXT
SET WILDCARD=*.*

SET SHOWNCSVHEADER=N

:PARSE
IF /I "%~1" == "/?"     SET USAGE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-?"     SET USAGE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/X"     SET DEBUG=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-X"     SET DEBUG=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/MB"    SET MASTERBRANCH=%~2&& SHIFT &&SHIFT && GOTO :PARSE
IF /I "%~1" == "-MB"    SET MASTERBRANCH=%~2&& SHIFT &&SHIFT && GOTO :PARSE
IF /I "%~1" == "/R"     SET RECURSECHILDREN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-R"     SET RECURSECHILDREN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/S"     SET RECURSECHILDREN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-S"     SET RECURSECHILDREN=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/OT"    SET OUTPUTTYPE=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-OT"    SET OUTPUTTYPE=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/NF"    SET NOTESFILE=%~dpnx2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-NF"    SET NOTESFILE=%~dpnx2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "/SOM"   SET SHOWONMASTER=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SOM"   SET SHOWONMASTER=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SOM-"  SET SHOWONMASTER=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SOM-"  SET SHOWONMASTER=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/UOM"   SET UPDATEONMASTER=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-UOM"   SET UPDATEONMASTER=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/UOM-"  SET UPDATEONMASTER=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-UOM-"  SET UPDATEONMASTER=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SOOD"  SET SHOWOUTOFDATE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SOOD"  SET SHOWOUTOFDATE=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SOOD-" SET SHOWOUTOFDATE=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SOOD-" SET SHOWOUTOFDATE=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SW"    SET SHOWWIP=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SW"    SET SHOWWIP=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SW-"   SET SHOWWIP=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SW-"   SET SHOWWIP=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SN"    SET SHOWNOTES=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SN"    SET SHOWNOTES=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/SN-"   SET SHOWNOTES=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-SN-"   SET SHOWNOTES=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/W"     SET WILDCARD=%~2&& SHIFT && SHIFT && GOTO :PARSE
IF /I "%~1" == "-W"     SET WILDCARD=%~2&& SHIFT && SHIFT && GOTO :PARSE

IF NOT "%~1" == "" (
  IF %POS% == 1 (
    SET FOLDER=%~1
  )
  SHIFT
  SET /A POS+=1
  GOTO :PARSE
)

IF "%DEBUG%" == "Y" (
  ECHO.DEBUG           = [%DEBUG%]
  ECHO.USAGE           = [%USAGE%]
  ECHO.FOLDER          = [%FOLDER%]
  ECHO.RECURSECHILDREN = [%RECURSECHILDREN%]
  ECHO.MASTERBRANCH    = [%MASTERBRANCH%]
  ECHO.SHOWONMASTER    = [%SHOWONMASTER%]
  ECHO.SHOWOUTOFDATE   = [%SHOWOUTOFDATE%]
  ECHO.SHOWWIP         = [%SHOWWIP%]
  ECHO.SHOWNOTES       = [%SHOWNOTES%]
  ECHO.UPDATEONMASTER  = [%UPDATEONMASTER%]
  ECHO.NOTESFILE       = [%NOTESFILE%]
  ECHO.OUTPUTTYPE      = [%OUTPUTTYPE%]
  ECHO.WILDCARD        = [%WILDCARD%]
)

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

:GO
IF NOT "%FOLDER%" == "" PUSHD "%FOLDER%"

IF "%RECURSECHILDREN%" == "Y" (
  FOR /D %%F IN (%WILDCARD%) DO CALL :CHECKFOLDER "%%~dpnxF"
) ELSE (
  CALL :CHECKFOLDER "%CD%"
)

IF NOT "%FOLDER%" == "" POPD

TITLE

GOTO :EOF


:USAGE
ECHO.%~n0 - Show status of git folders than are not on %MASTERBRANCH%
ECHO.
ECHO.%~n0 [folder] [options]
ECHO.
ECHO.[folder]     - Folder to check
ECHO.
ECHO.Options:
ECHO.-mb [name]     - Specify the name of the master branch (Default: %MASTERBRANCH%)
ECHO.-r / -s        - Recurse sub-folders
ECHO.-ot [value]    - Specify the Output Type [TXT / CSV] (Default: %OUTPUTTYPE%)
ECHO.-nf [filename] - Specify the Notes filename to inject notes from
ECHO.-som[-]        - Show output if on main branch (Default: %SHOWONMASTER%)
ECHO.-uom[-]        - Update (pull) if on main branch (Default: %UPDATEONMASTER%)
ECHO.-sood[-]       - Show Out of Date commits (Default: %SHOWOUTOFDATE%)
ECHO.-sw[-]         - Show Work In Progress (Default: %SHOWWIP%)
ECHO.-sn[-]         - Show Notes (Default: %SHOWNOTES%)
ECHO.-w [folders]   - Set wildcard (Default: %WILDCARD%)
ECHO.-x             - Debug (Default: %DEBUG%)

GOTO :EOF


:CHECKFOLDER
SET REPOPATH=%~1
SET REPONAME=%~nx1

TITLE %~n0: %REPOPATH%

PUSHD "%REPOPATH%"

SET GITFAILURE=
SET SHOWNAME=Y
SET OUTOFDATE=
SET BRANCH=
SET WIP1=
SET WIP2=
SET WIP=
SET NOTES=

@IF "%DEBUG%" == "Y" @ECHO ON
FOR /F "delims=" %%i IN ('git status -b 2^>^&1 ^| grep -i "^fatal" ^| grep -i " not a git repository"') DO SET GITFAILURE=%%i
IF NOT "%GITFAILURE%" == "" ECHO.%REPOPATH% && CALL :ERROR "%GITFAILURE%" && GOTO :CHECKDONE
REM SET GITFAILURE=%GITFAILURE:)=%
REM SET GITFAILURE=%GITFAILURE:(=%

REM Check Git Status
FOR /F "tokens=3" %%i IN ('git status -b ^| grep -i "^On branch" 2^>^&1') DO SET BRANCH=%%i
FOR /F "delims=" %%i IN ('git status -b ^| grep -i "^Your branch is behind"') DO SET OUTOFDATE=%%i
FOR /F "delims=" %%i IN ('git status -b ^| grep -i "^Changes not staged for commit:"') DO SET WIP1=%%i
FOR /F "delims=" %%i IN ('git status -b ^| grep -i "^Untracked files:"') DO SET WIP2=%%i
IF NOT "%NOTESFILE%" == "" CALL :READNOTES

IF NOT "%WIP1%" == "" (
  IF "%WIP%" == "" (
    SET WIP=%WIP1%
  ) ELSE (
    SET WIP=%WIP%%WIP1%
  )
)
IF NOT "%WIP2%" == "" (
  IF "%WIP%" == "" (
    SET WIP=%WIP2%
  ) ELSE (
    SET WIP=%WIP%%WIP2%
  )
)

IF NOT "%WIP%" == "" (
  SET WIP=WIP:%WIP%
)

IF /I "%OUTPUTTYPE%" == "TXT" CALL :SHOWTXT
IF /I "%OUTPUTTYPE%" == "CSV" CALL :SHOWCSV

IF /I "%BRANCH%" == "%MASTERBRANCH%" (
  IF "%UPDATEONMASTER%" == "Y" (
    IF NOT "%OUTOFDATE%" == "" (
      IF "%WIP%" == "" (
        ECHO.  Pulling...
        CALL :PULLFROMREMOTE
      )
    )
  )
)

:CHECKDONE
@IF "%DEBUG%" == "Y" @ECHO OFF
POPD

GOTO :EOF


:READNOTES
FOR /F "delims=" %%i IN ('grep "^%REPONAME%," "%NOTESFILE%" ^| sed -e "s/%REPONAME%,//g" 2^>^&1') DO SET NOTES=%%i
GOTO :EOF


:PULLFROMREMOTE
git pull --quiet >nul 2>&1

GOTO :EOF


:SHOWTXT
SET SHOWBRANCH=N
IF NOT "%BRANCH%" == "" SET SHOWBRANCH=Y
IF "%BRANCH%" == "%MASTERBRANCH%" (
  IF NOT "%SHOWONMASTER%" == "Y" SET SHOWBRANCH=N
)

IF "%SHOWBRANCH%" == "Y" (
  IF "%SHOWNAME%" == "Y" ECHO.%REPOPATH%
  ECHO.  %BRANCH%
  SET SHOWNAME=N
)

IF NOT "%OUTOFDATE%" == "" (
  IF "%SHOWOUTOFDATE%" == "Y" (
    IF "%SHOWNAME%" == "Y" ECHO.%REPOPATH%
    ECHO.  %OUTOFDATE%
    SET SHOWNAME=N
  )
)

IF NOT "%NOTES%" == "" (
  IF "%SHOWNOTES%" == "Y" (
    ECHO.  %NOTES%
    SET SHOWNOTES=N
  )
)

GOTO :EOF


:SHOWCSV
SET LINE=

SET SHOWBRANCH=N
IF NOT "%BRANCH%" == "" SET SHOWBRANCH=Y
IF "%BRANCH%" == "%MASTERBRANCH%" (
  IF NOT "%SHOWONMASTER%" == "Y" SET SHOWBRANCH=N
)

SET FIELD=
IF "%SHOWBRANCH%" == "Y" (
  SET FIELD=%BRANCH%
)
SET LINE=%LINE%,%FIELD%

SET FIELD=
IF NOT "%WIP%" == "" (
  IF "%SHOWWIP%" == "Y" (
    IF NOT "%LINE%" == "" (
      SET FIELD=%WIP%
    )
  )
)
SET LINE=%LINE%,%FIELD%

SET FIELD=
IF NOT "%OUTOFDATE%" == "" (
  IF "%SHOWOUTOFDATE%" == "Y" (
    IF NOT "%LINE%" == "" (
      SET FIELD=%OUTOFDATE%
    )
  )
)
SET LINE=%LINE%,%FIELD%

SET FIELD=
IF NOT "%NOTES%" == "" (
  IF "%SHOWNOTES%" == "Y" (
    IF NOT "%LINE%" == "" (
      SET FIELD=%NOTES%
    )
  )
)
SET LINE=%LINE%,%FIELD%

IF NOT "%LINE%" == ",,,," (
  IF "%SHOWNCSVHEADER%" == "N" ECHO.Repo Path,Repo Name,Current Branch,WIP,Status,Notes
  ECHO.%REPOPATH%,%REPONAME%%LINE%
  SET SHOWNCSVHEADER=Y
)

GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF
