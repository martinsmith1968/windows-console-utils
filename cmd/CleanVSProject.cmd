@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

IF NOT EXIST "%~1" (
    CALL :ERROR "Project file does not exist - %~1"
    GOTO :EOF
)

SET LISTONLY=N
SET CLEAROBJ=N
SET CLEARBIN=N
SET CLEARXMLDOC=N

:PARSEOPTIONS
IF /I "%~2" == "/L" SET LISTONLY=Y
IF /I "%~2" == "-L" SET LISTONLY=Y
IF /I "%~2" == "/O" SET CLEAROBJ=Y
IF /I "%~2" == "-O" SET CLEAROBJ=Y
IF /I "%~2" == "/B" SET CLEARBIN=Y
IF /I "%~2" == "-B" SET CLEARBIN=Y
IF /I "%~2" == "/X" SET CLEARXMLDOC=Y
IF /I "%~2" == "-X" SET CLEARXMLDOC=Y

SHIFT /2

IF NOT "%~2" == "" GOTO :PARSEOPTIONS

CALL :CLEANPROJECT "%~1"

GOTO :EOF


:USAGE
ECHO %~n0 - Remove all binary and intermediate files and folders from a VS Project
ECHO.
ECHO.Usage:
ECHO.%~n0 [project-file-name] { [options] }
ECHO. Options: 
ECHO. /L - List folders to be cleared - don't actually clear them
ECHO. /O - clear Obj folder too
ECHO. /B - clear bin folder too
ECHO. /X - Clear XML documentation file too
GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:CLEANPROJECT
IF "%~1" == "" GOTO :EOF

CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.OutputPaths.tmp"
SET TEMPFILENAME=%UNIQUETEMPFILENAME%

REM XMLStarlet doesn't work
REM XML SEL -T -t -m "/Project/PropertyGroup" -v "OutputPath" --nl "%~1" > "%TEMPFILENAME1%"

SET PROJECTPATH=%~dp1

GREP -i "OutputPath" "%~1" | AWK -F "<" "{ print $2 }" | AWK -F ">" "{ print $2 }" | UNIQ > "%TEMPFILENAME%"

FOR /F %%F IN (%TEMPFILENAME%) DO (
    ECHO.Clearing: %PROJECTPATH%%%F
    IF NOT "%LISTONLY%" == "Y" (
        CALL CLEARDIR.CMD "%PROJECTPATH%%%F" > NUL
    )
    
    IF "%CLEAROBJ%" == "Y" (
        ECHO.Clearing: %PROJECTPATH%obj
        IF NOT "%LISTONLY%" == "Y" (
            CALL CLEARDIR.CMD "%PROJECTPATH%obj" /k > NUL
        )
    )
    
    IF "%CLEARBIN%" == "Y" (
        ECHO.Clearing: %PROJECTPATH%bin
        IF NOT "%LISTONLY%" == "Y" (
            CALL CLEARDIR.CMD "%PROJECTPATH%bin" /k > NUL
        )
    )
)

IF EXIST "%TEMPFILENAME%" DEL "%TEMPFILENAME%" > NUL

CALL :CLEANPROJECTXMLDOC "%~1"

GOTO :EOF


:CLEANPROJECTXMLDOC
IF "%~1" == "" GOTO :EOF

IF NOT "%CLEARXMLDOC%" == "Y" GOTO :EOF

CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.DocumentationFile.tmp"
SET TEMPFILENAME=%UNIQUETEMPFILENAME%

SET PROJECTPATH=%~dp1

GREP -i "DocumentationFile" "%~1" | AWK -F "<" "{ print $2 }" | AWK -F ">" "{ print $2 }" | UNIQ > "%TEMPFILENAME%"

FOR /F %%F IN (%TEMPFILENAME%) DO (
    ECHO.Removing: %PROJECTPATH%%%F
    IF NOT "%LISTONLY%" == "Y" (
        IF EXIST "%PROJECTPATH%%%F" (
            DEL "%PROJECTPATH%%%F" > NUL
        )
    )
)

IF EXIST "%TEMPFILENAME%" DEL "%TEMPFILENAME%" > NUL

GOTO :EOF
