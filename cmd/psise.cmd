@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET APPTITLE=PowerShell ISE
SET APPDESC=Edit a file in %APPTITLE%
SET APPPARAMS=[filename]

SET APPFOLDER=WindowsPowerShell\v1.0
SET APPEXE=PowerShell_ISE.exe

CALL %SCRIPTPATH%FINDAPP.CMD %APPFOLDER% %APPEXE%
IF EXIST "%APP%" GOTO :APPOK


:APPBAD
CALL :ERROR "%APPTITLE% is not installed or is not available"
GOTO :EOF


:APPOK
IF "%~1" == "" (
	CALL :USAGE
	GOTO :EOF
)


:START
START "%APPTITLE%" "%APP%" %1
GOTO :EOF


:USAGE
ECHO.%~n0 - %APPDESC%
ECHO.
ECHO.Usage: %~n0 %APPPARAMS%

GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF
