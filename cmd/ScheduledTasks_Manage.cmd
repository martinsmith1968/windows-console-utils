@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET TASK=

IF /I "%~1" == "INSTALL" (
    SET TASK=%~1
    SHIFT
) ELSE IF /I "%~1" == "UNINSTALL" (
    SET TASK=%~1
    SHIFT
)

SET OWNER=MartinSmith
IF NOT "%~1" == "" SET OWNER=%~1

IF "%TASK%" == "" (
    CALL :USAGE
    GOTO :EOF
)

GOTO %TASK%
GOTO :EOF

:USAGE
ECHO.%SCRIPTNAME% - Manage known scheduled tasks
ECHO.
ECHO.%SCRIPTNAME% INSTALL   { owner:MartinSmith }
ECHO.%SCRIPTNAME% UNINSTALL { owner:MartinSmith }

GOTO :EOF


:INSTALL
SCHTASKS /create /F /TN "%OWNER%\ClearTemp"         /TR "%SCRIPTPATH%\ClearTemp.cmd"                                                                        /SC daily   /ST 20:00 /MO 1
SCHTASKS /create /F /TN "%OWNER%\ClockTime"         /TR "%SCRIPTPATH%\..\bin\TaskbarAlert /Type:TIME /TimeToStay:3000"                                      /SC minute  /ST 00:00 /MO 15
SCHTASKS /create /F /TN "%OWNER%\PacktFreeLearning" /TR "%SCRIPTPATH%\EXEC https://www.packtpub.com/packt/offers/free-learning"                             /SC daily   /ST 11:00 /MO 1
SCHTASKS /create /F /TN "%OWNER%\GoHome"            /TR "%SCRIPTPATH%\..\bin\TaskbarAlert /Type:WarningText /Text:\"Time to go Home!!!\" /Title:{stime}"    /SC minute  /ST 18:01 /MO 15 /ET 20:01
SCHTASKS /create /F /TN "%OWNER%\Lunchtime"         /TR "%SCRIPTPATH%\..\bin\TaskbarAlert /Type:WarningText /Text:\"Lunch Time !!!\" /Title:{stime}"        /SC daily   /ST 12:01 /MO 1  /DU 2:00 /RI 15
SCHTASKS /create /F /TN "%OWNER%\TwoMinuteSilence"  /TR "msg "%USERNAME%" \"2 minute silence\""                                                             /SC monthly /ST 10:55 /MO 11 /SD 11/11/2000 /D 11
SCHTASKS /create /F /TN "%OWNER%\GITWIP"            /TR "C:\Dev\cbg\wip.cmd"                                                                                /SC daily   /ST 21:00 /MO 1

CALL ScheduledTasks_List.cmd "%~1"

GOTO :EOF


:UNINSTALL
SCHTASKS /delete /F /TN "%OWNER%\ClearTemp"
SCHTASKS /delete /F /TN "%OWNER%\ClockTime"
SCHTASKS /delete /F /TN "%OWNER%\PacktFreeLearning"
SCHTASKS /delete /F /TN "%OWNER%\GoHome"
SCHTASKS /delete /F /TN "%OWNER%\Lunchtime"
SCHTASKS /delete /F /TN "%OWNER%\TwoMinuteSilence"
SCHTASKS /delete /F /TN "%OWNER%\GITWIP"

CALL ScheduledTasks_List.cmd "%~1"

GOTO :EOF
