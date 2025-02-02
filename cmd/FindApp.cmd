@ECHO OFF

SET SHOWAPP=N

:PARSEOPTS
IF /I "%~1" == "/S" SET SHOWAPP=Y&&SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-S" SET SHOWAPP=Y&&SHIFT && GOTO :PARSEOPTS

:GO
CALL :TRY "%ProgramFiles(x86)%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%ProgramFiles%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%ProgramFiles%\WindowsApps" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%AltProgramFiles(x86)%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%AltProgramFiles%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%ProgramData%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%AltProgramData%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%SystemDrive%\Utils" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%SystemDrive%\Utils\bin" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%SystemDrive%\Utils\msbin" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%SystemDrive%\Utils\SysInternals" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%WinDir%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%WinDir%\System32" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%APPDATA%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND

CALL :TRY "%LOCALAPPDATA%" %1 %2 %3 %4 %5 %6 %7 %8
IF EXIST "%APP%" GOTO :FOUND


:FAILED
SET APP=

GOTO :EXIT


:FOUND
IF "%SHOWAPP%" == "Y" ECHO.Found: %APP%
GOTO :EXIT


:EXIT
SET SHOWAPP=
GOTO :EOF


:TRY
SET APP=%~1
IF NOT "%~2" == "" SET APP=%~1\%~2
IF NOT "%~3" == "" SET APP=%~1\%~2\%~3
IF NOT "%~4" == "" SET APP=%~1\%~2\%~3\%~4
IF NOT "%~5" == "" SET APP=%~1\%~2\%~3\%~4\%~5
IF NOT "%~6" == "" SET APP=%~1\%~2\%~3\%~4\%~5\%~6
IF NOT "%~7" == "" SET APP=%~1\%~2\%~3\%~4\%~5\%~6\%~7
IF NOT "%~8" == "" SET APP=%~1\%~2\%~3\%~4\%~5\%~6\%~7\%~8

GOTO :EOF
