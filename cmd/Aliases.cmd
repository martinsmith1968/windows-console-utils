@ECHO OFF

REM ** Apply Macros
IF EXIST "%~dp0\doskey.mac" (
    IF /I NOT "%DOSKEY_MAC%" == "HIDE" (
        ECHO.Applying doskey.mac...
    )
    @DOSKEY /MACROFILE=%~dp0\doskey.mac
)
