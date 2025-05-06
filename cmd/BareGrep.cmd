@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET APPTITLE=BareGrep
SET APPDESC=Search for files in folders

SET APPFOLDER=BareMetalSoft
SET APPEXE=baregrep.exe

CALL %SCRIPTPATH%FINDAPP.CMD %APPFOLDER% %APPEXE%
IF EXIST "%APP%" GOTO :APPOK


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


:USAGE
ECHO.baregrep [options] [pattern {file(s)}]
ECHO.
ECHO.or
ECHO.
ECHO.baregrep (-n / --no-regex) [options] {file(s)}
ECHO.
ECHO.where options can be:
ECHO.
ECHO.-n
ECHO.--no-regex
ECHO.
ECHO.Indicates that no regex (search string) will be specified on the command line, so matching files will be found, instead of matching lines in matching files.
ECHO.
ECHO.-i
ECHO.--ignore-case
ECHO.
ECHO.Case insensitive search (default search is case sensitive).
ECHO.
ECHO.-v
ECHO.--invert-match
ECHO.
ECHO.Shows only lines which do not match the expression.
ECHO.
ECHO.-r
ECHO.--search-subfolders
ECHO.
ECHO.Recursively searches from the current directory through all sub-folders, for any matching files. This is the default.
ECHO.
ECHO.-l
ECHO.--local-directory
ECHO.
ECHO.Searches only the current directory for matching files.
ECHO.
ECHO.-d directory
ECHO.--directory directory
ECHO.
ECHO.Specifies the directory in which to run BareGrep.
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
