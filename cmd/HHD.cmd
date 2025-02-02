@ECHO OFF

SETLOCAL

SET APPARGS=%*
SET APPARGS=%APPARGS:/?=-?%

CALL "%~dp0\StartApp.cmd" /n "%~n0" /t "Hex Editor Neo" /e "HexFrame.exe" /f "HHD Software" /s "Hex Editor Neo" /d "Edit a file in HHD Hex Editor Neo" /od "[filename]" /us /rac 1 %APPARGS%

GOTO :EOF


@ECHO OFF

IF [%*] == [-?] GOTO USAGE
IF [%*] == [/?] GOTO USAGE
IF "%~1" == ""  GOTO USAGE

START "HHD Hex Editor" "%ProgramFiles%\HHD Software\Hex Editor Neo\HexFrame.exe" %*
GOTO :EOF

:USAGE
ECHO.%~n0 {file(s)}
ECHO.
