@ECHO OFF

SETLOCAL EnableDelayedExpansion

IF "%~1" == "" (
    ECHO.%~n0 - Time a command
    ECHO.
    ECHO.%~n0 [command [parameters] [..]]
    GOTO :EOF
)

TimerCmd %~1 /c:start /q

%*

ECHO.
TimerCmd %~1 /c:stop /q
