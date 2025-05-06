@ECHO OFF

SETLOCAL

PUSHD "%~dp0"

CALL CreateStartupShortcut.cmd ..\DirMenu.exe

POPD
