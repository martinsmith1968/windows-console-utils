@ECHO OFF

IF "%~2" == ""  GOTO USAGE

START "AptDiff" "%ProgramFiles(x86)%\Brother Technology\AptEdit Lite 5\aptdiff.exe" "%~1" "%~2" %3 %4 %5 %6 %7 %8
GOTO :EOF

:USAGE
ECHO.%~n0 {file1} {file2}
ECHO.
