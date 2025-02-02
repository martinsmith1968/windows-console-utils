@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET APPTITLE=BareTail
SET APPDESC=Follow a file in %APPTITLE%
SET APPPARAMS=[filename]

SET APPFOLDER=BareMetalSoft
SET APPEXE=baretail.exe

CALL "%SCRIPTPATH%FINDAPP.CMD" %APPFOLDER% %APPEXE%
IF EXIST "%APP%" GOTO APPOK


:APPBAD
CALL :ERROR "%APPTITLE% is not installed or is not available"
GOTO :EOF


:APPOK
IF [%~1] == [-?] GOTO USAGE
IF [%~1] == [/?] GOTO USAGE

IF "%~1" == "" (
	CALL :USAGE
	GOTO :EOF
)


:START
START "%APPTITLE%" "%APP%" %1
GOTO :EOF


:ERROR
ECHO.Error: %~1
GOTO :EOF


:USAGE
ECHO.Command Line Use
ECHO.
ECHO.baretail [options] {file(s)}
ECHO.
ECHO.where options can be:
ECHO.
ECHO.-wp left top width height
ECHO.--window-position left top width height
ECHO.
ECHO.Specifies the window position at startup in pixels. Note that the -ws, --window-state option, as well as the stored windows state in the registry (from the last run) overrides this option when the state is minimised or maximised.
ECHO.
ECHO.-ws 0 / 1 / 2
ECHO.--window-state 0 / 1 / 2
ECHO.
ECHO.Specifies the window state at startup:
ECHO.
ECHO.0 - Normal state (neither minimised or maximised)
ECHO.1 - Minimised
ECHO.2 - Maximised
ECHO.
ECHO.-tc count -ti index
ECHO.--tile-window-count count --tile-window-index index 
