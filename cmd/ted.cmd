@ECHO OFF

IF "%~1" == "" (
	CALL :USAGE
	GOTO :EOF
)

START "TotalEdit Pro" "C:\Program Files (x86)\CoderTools\TotalEdit-Pro\TEditPro.exe" %1

GOTO :EOF

:USAGE
ECHO.%~n0 - Edit a file in TotalEdit
ECHO.
ECHO.Usage: %~n0 [filename]

GOTO :EOF
