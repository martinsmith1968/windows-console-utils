@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET MAPPING1=E:,USERPROFILE,%USERPROFILE%\Dev
SET MAPPING2=E:,ALTUSERPROFILE,%ALTUSERPROFILE%\Dev

REM ECHO.************************************************************
REM ECHO.** COMPUTER     : %COMPUTERNAME%
REM ECHO.** LOGON SERVER : %LOGONSERVER%
REM ECHO.**
REM ECHO.** USER         : \\%USERDOMAIN%\%USERNAME%
REM ECHO.** USERPROFILE  : \\%USERPROFILE%
REM ECHO.************************************************************
REM ECHO.
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0        "COMPUTER      : %COMPUTERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "LOGON SERVER  : %LOGONSERVER%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 " "
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USERNAME      : %USERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USER          : \\%USERDOMAIN%\%USERNAME%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "USERPROFILE   : \\%USERPROFILE%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "APPDATA       : \\%APPDATA%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 2 -tsc 2 -fln 0 -hln 0 "LOCAL APPDATA : \\%LOCALAPPDATA%"
%SCRIPTPATH%\msbin\BANNERTEXT -minl 78 -tpc 0 -tsc 0 -fln 0 -tpc 0 " "


:ENVIRONMENT
SETX DIRCMD /OGEN

CALL %SCRIPTPATH%\cmd\Aliases.Cmd
%SYSTEMROOT%\System32\DOSKEY /MACROS


:MAP_E
IF NOT EXIST "E:\*.*" (
  IF NOT "%USERPROFILE%" == "" (
    IF EXIST "%USERPROFILE%\Dev" (
      SUBST E: "%USERPROFILE%\Dev"
    )
  )
)
IF NOT EXIST "E:\*.*" (
  IF NOT "%ALTUSERPROFILE%" == "" (
    IF EXIST "%ALTUSERPROFILE%\Dev" (
      SUBST E: "%ALTUSERPROFILE%\Dev"
    )
  )
)
IF NOT EXIST "E:\*.*" (
  IF NOT "%SYSTEMDRIVE%" == "" (
    IF EXIST "%SYSTEMDRIVE%\Dev" (
      SUBST E: "%SYSTEMDRIVE%\Dev"
    )
  )
)
IF NOT EXIST "E:\*.*" (
  IF NOT "%USERPROFILE%" == "" (
    IF EXIST "%USERPROFILE%\Source" (
      SUBST E: "%USERPROFILE%\Source"
    )
  )
)
IF NOT EXIST "E:\*.*" (
  IF NOT "%ALTUSERPROFILE%" == "" (
    IF EXIST "%ALTUSERPROFILE%\Source" (
      SUBST E: "%ALTUSERPROFILE%\Source"
    )
  )
)
IF NOT EXIST "E:\*.*" (
  IF EXIST "%SYSTEMDRIVE%\Dev" (
    SUBST E: "%SYSTEMDRIVE%\Dev"
  )
)
IF NOT EXIST "E:\*.*" (
  IF EXIST "%SYSTEMDRIVE%\Source" (
    SUBST E: "%SYSTEMDRIVE%\Source"
  )
)


:MAP_O
IF NOT EXIST "O:\*.*" (
    IF EXIST "%USERPROFILE%\Dropbox" (
        SUBST O: "%USERPROFILE%\Dropbox"
    )
)
IF NOT EXIST "O:\*.*" (
    IF EXIST "%USERPROFILE%\My Dropbox" (
        SUBST O: "%USERPROFILE%\My Dropbox"
    )
)


:MAP_P
IF NOT EXIST "P:\*.*" (
  IF EXIST "%USERPROFILE%\Projects" (
    SUBST P: "%USERPROFILE%\Projects"
  )
)


:CUSTOM
IF EXIST "%USERPROFILE%\MyLogin.cmd" (
  ECHO.Executing: %USERPROFILE%\MyLogin.cmd
  CALL "%USERPROFILE%\MyLogin.cmd"
)


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
