@ECHO OFF

REG ADD "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_EXPAND_SZ /d "%~dp0\AutoRun.cmd" /f
