@ECHO OFF

IF "%~1" == ""  GOTO USAGE

START "AptEdit" "%ProgramFiles(x86)%\Brother Technology\AptEdit Lite 5\aptedit.exe" %*
GOTO :EOF

:USAGE
ECHO.%~n0 {file1}
ECHO.
