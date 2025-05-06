@ECHO OFF

SETLOCAL

FOR /F "tokens=1* delims=" %%A IN ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions /f name /v name /s ^| FINDSTR /c:"Name" ^| SORT') DO (
    FOR /F "tokens=3" %%X IN ("%%A") DO ECHO %%X
)
