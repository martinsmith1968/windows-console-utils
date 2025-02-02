@ECHO OFF

CALL ClearDir.CMD %TEMP%
CALL ClearDir.CMD %TMP%
CALL ClearDir.CMD "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files"
CALL ClearDir.CMD "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5"
CALL ClearDir.CMD "%USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer"
CALL ClearDir.CMD "%USERPROFILE%\AppData\Local\Temp\"
CALL ClearDir.CMD "C:\Temp"
CALL ClearDir.CMD "C:\Windows\Temp"


DEL /F /S  /Q "%USERPROFILE%\AppData\Local\Microsoft\Windows Live Mesh\*.log"
DEL /F /S  /Q "%USERPROFILE%\AppData\Local\Microsoft\Windows Live\*.log"
DEL /F /S  /Q "%USERPROFILE%\AppData\Local\Microsoft\Windows Live Sync\*.etl"
