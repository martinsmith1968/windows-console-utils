@ECHO OFF

SETLOCAL

REM Inspired by : https://stackoverflow.com/questions/34471956/how-do-i-determine-if-im-in-powershell-or-cmd

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N

SET VIEW=N

:PARSEARGS
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSEARGS
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSEARGS
IF /I "%~1" == "/V" SET VIEW=/S&&SHIFT&&GOTO :PARSEARGS
IF /I "%~1" == "-V" SET VIEW=/S&&SHIFT&&GOTO :PARSEARGS

FOR /F "tokens=*" %%A IN ('(dir 2>&1 *`|echo CMD);&<# rem #>echo PowerShell') DO (
    IF "%VIEW%" == "Y" ECHO %%A
)

ENDLOCAL && SET ENVIRONMENTTYPE=%%A
