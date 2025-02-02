@ECHO OFF

SETLOCAL EnableDelayedExpansion

IF "%~1" == "" (
    ECHO.%~n0 - Time a batch command
    ECHO.
    ECHO.%~n0 { /T [name] } [command [parameters] [..]]
    GOTO :EOF
)

TimerCmd %~1 /c:start /q

CALL %*

ECHO.
TimerCmd %~1 /c:stop /q
