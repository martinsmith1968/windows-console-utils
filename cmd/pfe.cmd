@ECHO OFF

IF [%*] == [-?] GOTO USAGE
IF [%*] == [/?] GOTO USAGE

START "PFE" "%ProgramFiles(x86)%\PFE\PFE32.exe" %*
GOTO :EOF

:USAGE
ECHO.%~n0 {file(s)}
ECHO.
