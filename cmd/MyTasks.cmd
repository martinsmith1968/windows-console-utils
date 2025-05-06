@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

:INITIALISE
SET HELP=N
SET DEBUG=N
SET DRYRUN=N
SET COMMAND=LIST
SET OWNER=MartinSmith
SET VERBOSE=N
SET ARGPOS=0

SET UTILSROOT=%SCRIPTPATH%..
IF NOT "%UTILS%" == "" SET UTILSROOT=%UTILS%

SET DEVROOT=C:\Dev
IF NOT "%DEV%" == "" SET DEVROOT=%DEV%

SET TASKCOUNT=0

REM CALL :ADDTASK   ClearTemp           "/TR "%UTILSROOT%\cmd\ClearTemp.cmd"                                                                 /SC daily   /ST 20:00 /MO 1"
REM CALL :ADDTASK   ClockTime           "/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:TIME /TimeToStay:3000"                                    /SC minute  /ST 00:00 /MO 15"
REM CALL :ADDTASK   PackTFreeLearning   "/TR \"%UTILSROOT%\cmd\EXEC https://www.packtpub.com/free-learning\"                                   /SC daily   /ST 11:00 /MO 1"
REM CALL :ADDTASK   StewartGolfSale     "/TR "%UTILSROOT%\cmd\EXEC https://shop.stewartgolf.co.uk/products/stewart-golf-q-follow"            /SC daily   /ST 11:00 /MO 1"
REM CALL :ADDTASK   GoHome              "/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:WarningText /Text:\"Time to go Home!!!\" /Title:{stime}"  /SC minute  /ST 18:01 /MO 15 /ET 20:01"
REM CALL :ADDTASK   LunchTime           "/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:WarningText /Text:\"Lunch Time !!!\" /Title:{stime}"      /SC daily   /ST 12:01 /MO 1  /DU 2:00 /RI 15"
REM CALL :ADDTASK   TwoMinutesSilence   "/TR "msg "%USERNAME%" "2 minute silence"""                                                         /SC monthly /ST 10:55 /MO 11 /SD 11/11/2000 /D 11"
REM CALL :ADDTASK   GITWIP              "/TR \"%DEVROOT%\wip.cmd\"                                                                             /SC daily   /ST 21:00 /MO 1"

GOTO :EOF

SET TASKARGS1=/TR "%UTILSROOT%\cmd\ClearTemp.cmd"                                                                 /SC daily   /ST 20:00 /MO 1
SET TASKARGS2=/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:TIME /TimeToStay:3000"                                    /SC minute  /ST 00:00 /MO 15
SET TASKARGS3=/TR "%UTILSROOT%\cmd\EXEC https://www.packtpub.com/free-learning"                                   /SC daily   /ST 11:00 /MO 1
SET TASKARGS4=/TR "%UTILSROOT%\cmd\EXEC https://shop.stewartgolf.co.uk/products/stewart-golf-q-follow"            /SC daily   /ST 10:00 /MO 1
SET TASKARGS5=/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:WarningText /Text:\"Time to go Home!!!\" /Title:{stime}"  /SC minute  /ST 18:01 /MO 15 /ET 20:01
SET TASKARGS6=/TR "%UTILSROOT%\msbin\TaskbarAlert /Type:WarningText /Text:\"Lunch Time !!!\" /Title:{stime}"      /SC daily   /ST 12:01 /MO 1  /DU 2:00 /RI 15
SET TASKARGS7=/TR "msg "%USERNAME%" \"2 minute silence\""                                                         /SC monthly /ST 10:55 /MO 11 /SD 11/11/2000 /D 11
SET TASKARGS8=/TR "%DEVROOT%\wip.cmd"                                                                             /SC daily   /ST 21:00 /MO 1


:CHECKTASKS
SET /A INDEX=%TASKCOUNT%+1
IF "!TASKNAME%INDEX%!" == "" GOTO :PARSE
SET TASKCOUNT=%INDEX%
GOTO :CHECKTASKS


:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET HELP=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/O" SET OWNER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-O" SET OWNER=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-V" SET VERBOSE=Y&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE


:VALIDATE
IF "%COMMAND%" == "" SET HELP=Y
IF "%HELP%" == "Y" (
    CALL :USAGE
    GOTO :EOF
)

GOTO :COMMAND_%COMMAND% 2>NUL
CALL :ERROR "Unknown Command : %COMMAND%"
GOTO :EOF


:ADDTASK
SET /A TASKCOUNT+=1

ECHO.-------------------------------------------------------
ECHO.INDEX=%TASKCOUNT%
ECHO NAME=[%~1]
ECHO.CMD=[%~2]
ECHO.SHIT=[%~3]

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Manage my scheduled tasks
ECHO.
ECHO.Usage: %SCRIPTNAME% [command] { [options] }
ECHO.
ECHO.Commands
ECHO.LIST           Show the defined commands in the console
ECHo.EDIT           Launch Task Scheduler
ECHO.INSTALL        Install the defined tasks
ECHO.UNINSTALL      Remove the known defined tasks
ECHO.
ECHO.Options:
ECHO./o [value]     Set the Task Owner (Default: %OWNER%)
ECHO./v             Activate verbose output (Default: %VERBOSE%)
ECHO./x             Activate Debug mode (Default: %DEBUG%)
ECHO./z             Activate Dry Run mode (Default: %DRYRUN%)

GOTO :EOF


:ERROR
ECHO.ERROR: %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8
GOTO :EOF


:COMMAND_LIST
SET PREFIX=
IF "%DRYRUN%" == "Y" SET PREFIX=ECHO.

SET OTHERARGS=
IF "%VERBOSE%" == "Y" SET OTHERARGS=%OTHERARGS% /V

SET INDEX=1
SET EXTRA=
:LIST_LOOP
IF %INDEX% GTR %TASKCOUNT% GOTO :EOF
SET TASKNAME=!TASKNAME%INDEX%!

IF "%DEBUG%" == "Y" ECHO.TASKNAME = %TASKNAME%
%PREFIX%SCHTASKS /query /FO table %EXTRA% %OTHERARGS% /TN "%OWNER%\%TASKNAME%"2>NUL

SET EXTRA=/NH
SET /A INDEX+=1
GOTO :LIST_LOOP


:COMMAND_EDIT
START %windir%\system32\taskschd.msc /s
GOTO :EOF


:COMMAND_INSTALL
SET PREFIX=
IF "%DRYRUN%" == "Y" SET PREFIX=ECHO.

SET INDEX=1
:INSTALL_LOOP
IF %INDEX% GTR %TASKCOUNT% GOTO :INSTALL_DONE
SET TASKNAME=!TASKNAME%INDEX%!
SET TASKARGS=!TASKARGS%INDEX%!

IF "%DEBUG%" == "Y" (
    ECHO.TASKNAME = %TASKNAME%
    ECHO.TASKARGS = %TASKARGS%
)
%PREFIX%SCHTASKS /create /F /TN "%OWNER%\%TASKNAME%" %TASKARGS%

SET /A INDEX+=1
GOTO :INSTALL_LOOP

:INSTALL_DONE
CALL :COMMAND_LIST

GOTO :EOF


:COMMAND_UNINSTALL
SET PREFIX=
IF "%DRYRUN%" == "Y" SET PREFIX=ECHO.

SET INDEX=1
:UNINSTALL_LOOP
IF %INDEX% GTR %TASKCOUNT% GOTO :UNINSTALL_DONE
SET TASKNAME=!TASKNAME%INDEX%!
SET TASKARGS=!TASKARGS%INDEX%!

IF "%DEBUG%" == "Y" (
    ECHO.TASKNAME = %TASKNAME%
    ECHO.TASKARGS = %TASKARGS%
)
%PREFIX%SCHTASKS /delete /F /TN "%OWNER%\%TASKNAME%" %TASKARGS%

SET /A INDEX+=1
GOTO :INSTALL_LOOP

:UNINSTALL_DONE
CALL :COMMAND_LIST

GOTO :EOF
