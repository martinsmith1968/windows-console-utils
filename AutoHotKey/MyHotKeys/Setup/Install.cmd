@ECHO OFF

SETLOCAL

PUSHD "%~dp0"

CALL CreateStartupShortcut.cmd ..\MyHotKeys.exe

POPD
