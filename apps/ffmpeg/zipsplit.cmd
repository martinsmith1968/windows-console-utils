REM @ECHO OFF

SETLOCAL

PUSHD "%dp~0"

FOR %%F IN (ffmpeg-2025-01-30*.7z) DO (
  ZIP %%F --out %%~dpnF-split.%%~xF -s 40m
)

POPD
