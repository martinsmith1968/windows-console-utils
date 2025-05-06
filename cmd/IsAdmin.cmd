@ECHO OFF

SET ISADMIN=N

NET SESSION >NUL 2>&1
IF %ERRORLEVEL% EQU 0 SET ISADMIN=Y

IF /I "%~1" == "/Q" GOTO :EOF

IF "%ISADMIN%" == "Y" (
  ECHO.Running as Administrator
) ELSE (
  ECHO.NOT Running as Administrator
)
