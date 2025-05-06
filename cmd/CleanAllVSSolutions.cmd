@ECHO OFF

SETLOCAL

SET SOLUTIONLIST=%~n0.tmp

ECHO.Locating Solution Files...
DIR "%~dp0\*.sln" /s /b > %SOLUTIONLIST%

FOR /F "delims=#" %%F IN (%SOLUTIONLIST%) DO (
    CALL :CLEARSOLUTION "%%F"
)

IF EXIST "%SOLUTIONLIST%" DEL /Q "%SOLUTIONLIST%" > NUL

GOTO :EOF


:CLEARSOLUTION
ECHO.Clearing Solution: %~1

CALL CleanVsSolution.cmd "%~1" /O /B /X

GOTO :EOF
