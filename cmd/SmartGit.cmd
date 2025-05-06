@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0

SET POS=0
SET ARGS=

:PARSEOPTS
SET /A POS+=1
IF NOT "%~1" == "" (
  IF %POS% EQU 1 (
    SET ARGS=%ARGS% --open "%~dpn1"
  ) ELSE (
    SET ARGS=%ARGS% "%~1"
  )
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "SmartGit" /e "smartgitc.exe" /f "SmartGit" /s "bin" /d "Open a Repo folder in SmartGit" /od "[folder] " /rac 1 /nqa %ARGS%
