@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFILENAME=%~nx0
SET SCRIPTFULLFILENAME=%~dpnx0

Stopwatch start "%SCRIPTNAME%"

PUSHD "%SCRIPTPATH%"

FOR /D %%F IN (*.*) DO CALL :HANDLE %%~F

POPD

Stopwatch stop "%SCRIPTNAME%" -v

GOTO :EOF


:HANDLE
ECHO.-------------------------------------------------------------------------------
ECHO.Processing : %~1

SET LOGFILENAME=%SCRIPTNAME%-%~1.txt

CALL GetDateTime.cmd

ECHO.Started at : %CURRENTDATETIME% > "%LOGFILENAME%"
ECHO. >> "%LOGFILENAME%"

python "c:\utils\python\gitwip.py" -d "%SCRIPTPATH%%~1" -m dir_of_dir_of_repos -sri -sonp -sood -pop -fpb -suc -slnpb -snpr | tee -a "%LOGFILENAME%"

ECHO. >> "%LOGFILENAME%"
ECHO.Ended at : %CURRENTDATETIME% >> "%LOGFILENAME%"

GOTO :EOF
