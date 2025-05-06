@ECHO OFF

REM ** Apply Macros
IF EXIST "%~dp0\doskey.mac" (
    IF /I NOT "%DOSKEY_MAC%" == "HIDE" (
        ECHO.Applying doskey.mac...
    )
    @%SYSTEMROOT%\System32\DOSKEY /MACROFILE=%~dp0\doskey.mac
)
