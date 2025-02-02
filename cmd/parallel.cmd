@ECHO OFF

SETLOCAL

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET COMMAND=
SET COUNT=0
SET CMDMODIFIER=/C
SET DEBUG=N
SET POS=1

:LOOP
IF /I "%~1" == "-X" (
    SET DEBUG=Y
    SHIFT
    GOTO :LOOP
)
IF /I "%~1" == "-K" (
    SET CMDMODIFIER=/K
    SHIFT
    GOTO :LOOP
)
IF NOT "%~1" == "" (
    IF %POS% == 1 (
        SET COUNT=%~1
        SHIFT
        SET /A POS+=1
        GOTO :LOOP
    ) ELSE IF %POS% == 2 (
        SET COMMAND=%~1
        SHIFT
        SET /A POS+=1
        GOTO :LOOP
    ) ELSE (
        ECHO.Error: Unknown switch: %~1
    SHIFT
    GOTO :LOOP
  )
)

:VALIDATE
IF "%COMMAND%" == "" CALL :USAGE && GOTO :EOF
IF %COUNT% LEQ 0     CALL :USAGE && GOTO :EOF

SET CMDPREFIX=
IF "%DEBUG%" == "Y" SET CMDPREFIX=ECHO.

:RUN
FOR /L %%F IN (1,1,%COUNT%) DO (
    ECHO.Starting Console: %%~F
    %CMDPREFIX%START "Console: %%F" CMD %CMDMODIFIER% %COMMAND%
)

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Run Console command in parallel
ECHO.
ECHO.%SCRIPTNAME% [instance-count] [command] { [options] }
ECHO.
ECHO.Options:
ECHO.-K   Keep Console windows open after run

GOTO :EOF
