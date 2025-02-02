@ECHO OFF

SETLOCAL

IF "%~1" == "" (
  ECHO.ERROR: No base path supplied
  GOTO :EOF
)

FOR %%F IN (%~dp0\NativeConsoleApps.*.zip) DO (
  ECHO.Extracting: %%~nxF
  CALL "%~1\cmd\tarextract" %%F *.exe -t "%~1\msbin"
)
