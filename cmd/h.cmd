@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET COMMANDEXTENSIONS=*.cmd *.bat *.ps1
SET EXECUTABLEEXTENSIONS=*.exe
SET EXTENSIONS=%EXECUTABLEEXTENSIONS% %COMMANDEXTENSIONS%
SET RECURSE=

:PARSEARGS
IF /I "%~1" == "/S" (
    SET RECURSE=/S
    SHIFT
    GOTO :PARSEARGS
)

IF NOT "%~1" == "" (
    SET MYFOLDER=%~1
    SHIFT
    GOTO :PARSEARGS
)

:SETDEFAULTS
IF "%MYFOLDER%" == "" (
    FOR %%* IN (.) DO SET MYFOLDER=%%~dpnx*
)
IF "%MYFOLDER%" == "" (
    FOR %%* IN (.) DO SET MYFOLDER=%%~dp*
)

SET DESCRIPTION=%MYFOLDER%
IF NOT "%RECURSE%" == "" SET DESCRIPTION=%DESCRIPTION% (and subfolders)

:GO
BANNERTEXT -hlc "=" -flc "=" -tlc "=" -tsc 0 "Commands for: %DESCRIPTION%"
ECHO.

SET REPLACE=%MYFOLDER:\=\\%
if "%MYFOLDER%" == "." SET REPLACE=
if "%MYFOLDER%" == ".." SET REPLACE=

PUSHD "%MYFOLDER%"

DIR %RECURSE% %EXTENSIONS% /B 2>&1 | SED -e "s/^%REPLACE%//g" -e "s/^\\//g" | SED -e "s/^File Not Found$/No commands found/g"

POPD

REM CALL BuildUniqueTempFileName.cmd %SCRIPTNAME%
REM SET EXECUTABLEOUTPUT=%UNIQUETEMPFILENAME%
REM 
REM CALL BuildUniqueTempFileName.cmd %SCRIPTNAME%
REM SET COMMANDOUTPUT=%UNIQUETEMPFILENAME%

REM DIR %RECURSE% %EXECUTABLEEXTENSIONS% /B 2>&1 | SED -e "s/^%MYFOLDER:\=\\%//g" -e "s/^\\//g" | SED -e "s/^File Not Found$/No commands found/g" > "%EXECUTABLEOUTPUT%"
REM DIR %RECURSE% %COMMANDEXTENSIONS% /B 2>&1    | SED -e "s/^%MYFOLDER:\=\\%//g" -e "s/^\\//g" | SED -e "s/^File Not Found$/No commands found/g" > "%COMMANDOUTPUT%"

REM FOR /F %%F IN (%COMMANDOUTPUT%) DO (
REM     @ECHO ON
REM     GREP -m 1 "^REM.*DESCRIPTION:" "%%~F" | SED -e "s/REM.*DESCRIPTION:/%%~F - /g" >> "%EXECUTABLEOUTPUT%"
REM     @ECHO OFF
REM )

REM TYPE "%EXECUTABLEOUTPUT%" >> "%COMMANDOUTPUT%"

REM UNIQ "%COMMANDOUTPUT%"
