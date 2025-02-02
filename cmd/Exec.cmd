@ECHO OFF

SETLOCAL

SET APP=
SET ARGS=
SET TITLE=
SET NEWWINDOW=
SET WAIT=
SET WINDOWSTATE=

SET POS=0

:PARSEOPTIONS
IF /I "%~1" == "/T"   SET TITLE=%~2         && SHIFT && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/B"   SET NEWWINDOW=/B      && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-B"   SET NEWWINDOW=/B      && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/W"   SET WAIT=/WAIT        && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-W"   SET WAIT=/WAIT        && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/MIN" SET WINDOWSTATE=/MIN  && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-MIN" SET WINDOWSTATE=/MIN  && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "/MAX" SET WINDOWSTATE=/MAX  && SHIFT && GOTO :PARSEOPTIONS
IF /I "%~1" == "-MAX" SET WINDOWSTATE=/MAX  && SHIFT && GOTO :PARSEOPTIONS

SET /A POS+=1
IF NOT "%~1" == "" (
  IF %POS% == 1 SET APP=%~1
  IF %POS% == 2 SET ARGS=%~1 %ARGS%
  
  SHIFT
  GOTO :PARSEOPTIONS
)

:VALIDATE
IF "%APP%" == "" CALL :USAGE && GOTO :EOF

:DOIT
ECHO.Executing: %APP% %ARGS%
START "%TITLE%" "%APP%" "%ARGS%" %NEWWINDOW% %WAIT% %WINDOWSTATE%

GOTO :EOF


:USAGE
ECHO %~n0 - Execute app app with arguments
ECHO.
ECHO.Usage:
ECHO.%~n0 [app] { [arguments] } { [options] }
ECHO.
ECHO.Options:
ECHO. /T ^| -T [title]  - Set a Title for the Window
ECHO. /B ^| -B          - Don't create new window
ECHO. /W ^| -W          - Wait for app to finish
ECHO. /MIN ^| -MIN      - Start Window minimized
ECHO. /MAX ^| -MAX      - Start Window maximized
ECHO.

GOTO :EOF
