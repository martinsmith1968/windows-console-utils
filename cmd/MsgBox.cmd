@ECHO OFF

SETLOCAL

IF "%~1" == "" (
    ECHO.Usage: %~n0 [text] { [text] ... }
    GOTO :EOF
)

MSHTA "about:<script>alert('%*');close()</script>"
