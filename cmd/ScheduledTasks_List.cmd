@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET OWNER=MartinSmith
IF NOT "%~1" == "" SET OWNER=%~1

SCHTASKS /query /FO table     /TN "%OWNER%\ClearTemp"
SCHTASKS /query /FO table /NH /TN "%OWNER%\ClockTime"
SCHTASKS /query /FO table /NH /TN "%OWNER%\PacktFreeLearning"
SCHTASKS /query /FO table /NH /TN "%OWNER%\GoHome"
SCHTASKS /query /FO table /NH /TN "%OWNER%\Lunchtime"
SCHTASKS /query /FO table /NH /TN "%OWNER%\TwoMinuteSilence"
