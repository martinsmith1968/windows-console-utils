@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0

SET TARGET=L
SET ARGS=

:PARSEOPTS
IF /I "%~1" == "/L" SET TARGET=L&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-L" SET TARGET=L&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/R" SET TARGET=R&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-R" SET TARGET=R&&SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  IF "%ARGS%" == "" (
    SET ARGS=%~1
  ) ELSE (
    SET ARGS=%ARGS% %~1
  )
  SHIFT
  GOTO :PARSEOPTS
)

"%SCRIPTPATH%\StartApp.cmd" /n "%~n0" /t "Double Commander" /e "doublecmd.exe" /f "Double Commander" /d "Open a folder in Double Commander" /od "[folder-name] /l ^| /r" /us /rac 1 /nqa /p "--no-splash -T -P %TARGET% -%TARGET% %ARGS%"
