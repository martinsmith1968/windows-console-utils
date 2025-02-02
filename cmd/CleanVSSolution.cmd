@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET SHOWUSAGE=N

IF "%~1" == ""   SET SHOWUSAGE=Y
IF "%~1" == "/?" SET SHOWUSAGE=Y
IF "%~1" == "-?" SET SHOWUSAGE=Y

IF "%SHOWUSAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)

SET OPTIONS=%*
SET SHOWPROJECT=Y

:PARSEOPTIONS
IF /I "%~2" == "/SP" SET SHOWPROJECT=Y
IF /I "%~2" == "-SP" SET SHOWPROJECT=Y
IF /I "%~2" == "/SP-" SET SHOWPROJECT=N
IF /I "%~2" == "-SP-" SET SHOWPROJECT=N

SHIFT /2

IF NOT "%~2" == "" GOTO :PARSEOPTIONS


IF EXIST "%~1\*.*" (
  CALL :FINDSOLUTIONS %OPTIONS%
  GOTO :EOF
)

IF EXIST "%~1" (
  CALL :DOSOLUTION %OPTIONS%
  GOTO :EOF
)

CALL :ERROR "Unable to find a solution file or folder at : %~1"

GOTO :EOF


:USAGE
ECHO %~n0 - Remove all binary and intermediate files and folders for all projects in a solution
ECHO.
ECHO.Usage:
ECHO.%~n0 [solution-file] ^| [solution-folder] { [options] }
ECHO. Options: 
ECHO. /L  - List folders to be cleared - don't actually clear them
ECHO. /O  - clear Obj folder too
ECHO. /B  - clear bin folder too
ECHO. /X  - Clear XML documentation file too
ECHO. /SP - Show Project details (/SP- to disable)
ECHO.
ECHO.If specifying a solution-folder, will use a .sln file if only one exists
GOTO :EOF


:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:DOSOLUTION
IF "%~1" == "" (
  CALL :ERROR "No solution file specified"
  GOTO :EOF
)

SET SOLUTIONPATH=%~dp1

CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.ProjectList.tmp"
SET TEMPFILENAMEPROJECTLIST=%UNIQUETEMPFILENAME%

GREP "^Project(" "%~1" | awk -F , "{ print $2 }" | sed -e "s/[ \t]*$//g" -e "s/'//g" -e "s/^[ \t]//"  > "%TEMPFILENAMEPROJECTLIST%"

FOR /F "delims=" %%F IN (%TEMPFILENAMEPROJECTLIST%) DO (
  IF "%SHOWPROJECT%" == "Y" (
    ECHO.Project: %SOLUTIONPATH%%%~F
  )
  CALL :DOPROJECT "%SOLUTIONPATH%%%~F" "%~2" "%~3"
)

IF EXIST "%TEMPFILENAMEPROJECTLIST%" DEL "%TEMPFILENAMEPROJECTLIST%" > NUL

GOTO :EOF


:FINDSOLUTIONS
IF "%~1" == "" (
  CALL :ERROR "No solution folder specified"
  GOTO :EOF
)

CALL BUILDUNIQUETEMPFILENAME "%SCRIPTNAME%.SolutionList.tmp"
SET TEMPFILENAMESOLUTIONLIST=%UNIQUETEMPFILENAME%

DIR "%~dpn1\*.sln" /b > "%TEMPFILENAMESOLUTIONLIST%"

FOR /F %%F IN (%TEMPFILENAMESOLUTIONLIST%) DO (
  CALL "%SCRIPTFULLFILENAME%" "%%~F" "%~2" "%~3"
)

IF EXIST "%TEMPFILENAMESOLUTIONLIST%" DEL "%TEMPFILENAMESOLUTIONLIST%" > NUL

GOTO :EOF


:DOPROJECT
IF "%~1" == "" GOTO :EOF
IF "%~x1" == "" GOTO :EOF

IF EXIST "%~1\*.*" GOTO :EOF
IF NOT EXIST "%~1" GOTO :EOF

CALL CleanVSProject.cmd %*

GOTO :EOF
