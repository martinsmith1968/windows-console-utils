@ECHO OFF

IF [%*] == [-?] GOTO USAGE
IF [%*] == [/?] GOTO USAGE
IF "%~1" == ""  GOTO USAGE

START "CSVed" "%ProgramFiles(x86)%\CSVed\csved.exe" %*
GOTO :EOF

:USAGE
ECHO.%~n0 {file(s)}
ECHO.
