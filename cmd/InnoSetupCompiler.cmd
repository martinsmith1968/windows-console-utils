@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET APPTITLE=Inno Setup Compiler
SET APPDESC=Inno Setup Command Line Compiler
SET APPPARAMS=[filename] { [options] }

SET APPFOLDER=Inno Setup 6
SET APPEXE=iscc.exe

CALL %SCRIPTPATH%FINDAPP.CMD "%APPFOLDER%" "%APPEXE%"
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
ECHO.Executing: %APPTITLE%
"%APP%" %*
GOTO :EOF


:USAGE
ECHO.%~n0 - %APPDESC%
ECHO.
ECHO.Usage: %~n0 %APPPARAMS%

GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF
