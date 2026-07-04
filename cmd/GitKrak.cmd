@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET VERBOSE=N
SET ARGPOS=0

SET ARGS=
SET FOLDER=.
SET FINDPARENTGIT=Y

:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "/X" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-X" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/V" SET VERBOSE=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-V" SET VERBOSE=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/FP"  SET FINDPARENTGIT=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-FP"  SET FINDPARENTGIT=Y&& SHIFT && GOTO :PARSE
IF /I "%~1" == "/FP-" SET FINDPARENTGIT=N&& SHIFT && GOTO :PARSE
IF /I "%~1" == "-FP-" SET FINDPARENTGIT=N&& SHIFT && GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET FOLDER=%~dpnx1&& SHIFT && GOTO :PARSE
IF %ARGPOS% EQU 2 SET ARGS=%ARGS% "%~1"&& SHIFT && GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unexpected argument as pos %ARGPOS% : %~1"
GOTO :EOF


:VALIDATE

:FINDFOLDER
CALL :ISGITFOLDER "%FOLDER%"
IF "%ISGITFOLDER%" == "Y" GOTO :GO

IF "%FINDPARENTGIT%" == "N" (
  CALL :ERROR "Not a git folder: %FOLDER%"
  GOTO :EOF
)

SET LASTFOLDER=%FOLDER%
CALL :GETFULLPATH "%FOLDER%\.."
SET FOLDER=%FULLPATH%

IF /I "%FOLDER%" == "%LASTFOLDER%" (
  CALL :ERROR "Not found a git folder: %FOLDER%"
  GOTO :EOF
)

ECHO.Checking: %FOLDER%
GOTO :FINDFOLDER


:GO
"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "GitKraken" /e "gitkraken.cmd" /f "gitkraken" /s "bin" /d "Open a Repo folder in GitKraken" /od "[folder] " /uc /rac 1 /nqa --path "%FOLDER%" %ARGS%

GOTO :EOF


REM --------------------------------------------------------------------------------
:USAGE
ECHO.%SCRIPTNAME% - Open GitKraken
ECHO.Usage: %~n0 [options]
ECHO.
ECHO.Options:
ECHO./C [configuration] - Set the build configuration
ECHO./A [arguments]     - Add the arguments 
ECHO./Q                 - Suppress output (Verbosity: quiet)
ECHo./Y [verbosity]     - Set the verbosity level (default: minimal) (q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic])
ECHO./Y[0-4]            - Set the Verbosity level (0=quiet, 1=minimal, 2=normal, 3=detailed, 4=diagnostic)

GOTO :EOF

:ERROR
ECHO.ERROR: %~1
GOTO :EOF


:GETFULLPATH
SET FULLPATH=%~dpnx1
GOTO :EOF


:ISGITFOLDER
SET ISGITFOLDER=N

IF "%~1" == "" GOTO :EOF

IF EXIST "%~1\.git\*.*" SET ISGITFOLDER=Y

GOTO :EOF
