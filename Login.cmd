@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

GOTO :START


REM ********************************************************************************
REM ----------
:ADDMAPPING
IF "%~3" == "" GOTO :EOF

SET /A DRIVE_MAPPING_COUNT+=1
SET MAPPING%DRIVE_MAPPING_COUNT%=%~1#%~2

GOTO :EOF

REM ----------
:MAP_DRIVE_BY_ID
SET MAPPINGNAME=MAPPING%~1
SET MAPPING=!%MAPPINGNAME%!
IF "%MAPPING%" == "" GOTO :EOF

FOR /F "TOKENS=1-2 DELIMS=#" %%A IN ("!MAPPING!") DO CALL :TRY_MAP_DRIVE "%%A" "%%B"

GOTO :EOF


REM ----------
:TRY_MAP_DRIVE
SET DRIVER_LETTERS=%~1
SET DRIVE_PATH=%~2

ECHO.Attempting to map : %DRIVE_PATH%

IF NOT EXIST "%DRIVE_PATH%\*.*" (
  ECHO. Path %DRIVE_PATH% does not exist. Skipping...
  GOTO :EOF
)

FOR %%L IN ("%DRIVER_LETTERS:,=" "%") DO (
  IF EXIST "%%L\*.*" (
    ECHO. Drive %%L is already mapped.
  ) ELSE (
    ECHO. Mapping Drive %%L to Path %DRIVE_PATH%
    SUBST "%%L" "%DRIVE_PATH%"
    GOTO :EOF
  )
)

GOTO :EOF

:START

REM ********************************************************************************
SET DRIVE_MAPPING_COUNT=0
CALL :ADDMAPPING "E:"    "%SYSTEMDRIVE%\Dev"          "%SYSTEMDRIVE%"
CALL :ADDMAPPING "E:"    "%USERPROFILE%\Dev"          "%USERPROFILE%"
CALL :ADDMAPPING "E:"    "%ALTUSERPROFILE%\Dev"       "%ALTUSERPROFILE%"
CALL :ADDMAPPING "E:,U:" "%SYSTEMDRIVE%\Source"       "%SYSTEMDRIVE%"
CALL :ADDMAPPING "E:,U:" "%USERPROFILE%\Source"       "%USERPROFILE%"
CALL :ADDMAPPING "E:,U:" "%ALTUSERPROFILE%\Source"    "%ALTUSERPROFILE%"
CALL :ADDMAPPING "E:,J:" "%SYSTEMDRIVE%\Projects"     "%SYSTEMDRIVE%"
CALL :ADDMAPPING "E:,J:" "%USERPROFILE%\Projects"     "%USERPROFILE%"
CALL :ADDMAPPING "E:,J:" "%ALTUSERPROFILE%\Projects"  "%ALTUSERPROFILE%"
CALL :ADDMAPPING "O:"    "%USERPROFILE%\Dropbox"      "%USERPROFILE%"
CALL :ADDMAPPING "O:"    "%USERPROFILE%\My Dropbox"   "%USERPROFILE%"


REM ********************************************************************************
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0        "COMPUTER       : %COMPUTERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "LOGON SERVER   : %LOGONSERVER%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 " "
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USERNAME       : %USERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USER           : \\%USERDOMAIN%\%USERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USERPROFILE    : \\%USERPROFILE%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "ALTUSERPROFILE : \\%ALTUSERPROFILE%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "APPDATA        : \\%APPDATA%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "LOCAL APPDATA  : \\%LOCALAPPDATA%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 0 -tsc 0 -fln 0 -tpc 0 " "


REM ********************************************************************************
:ENVIRONMENT
ECHO.
%SCRIPTPATH%\msbin\BANNERTEXT "Macros"
SETX DIRCMD /OGNE

CALL %SCRIPTPATH%\cmd\Aliases.Cmd INSTALL
CALL %SCRIPTPATH%\cmd\Aliases.Cmd LIST


REM ********************************************************************************
:MAP_DRIVES
ECHO.
%SCRIPTPATH%\msbin\BANNERTEXT "Drive Mappings"

ECHO.Count = %DRIVE_MAPPING_COUNT%
FOR /L %%I  IN (1,1,%DRIVE_MAPPING_COUNT%) DO CALL :MAP_DRIVE_BY_ID %%I


REM ********************************************************************************
:CUSTOM
IF EXIST "%USERPROFILE%\MyLogin.cmd" (
  ECHO.Executing: %USERPROFILE%\MyLogin.cmd
  CALL "%USERPROFILE%\MyLogin.cmd"
)


REM ********************************************************************************
:DISPLAY
ECHO.
%SCRIPTPATH%\msbin\BANNERTEXT "PATHs"
CALL %SCRIPTPATH%\cmd\paths.cmd

ECHO.
%SCRIPTPATH%\msbin\BANNERTEXT "Mapped Drives"
SUBST
NET USE

:EXIT
%SCRIPTPATH%\msbin\PAUSEN -t 10
