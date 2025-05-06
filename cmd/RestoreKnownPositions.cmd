@ECHO OFF

SETLOCAL

SET APPDATA=%USERPROFILE%\AppData

CALL :DOUBLECOMMANDER
CALL :NOTEPADPLUSPLUS
CALL :QUICKCALENDAR

CALL :DONE
GOTO :EOF


:DOUBLECOMMANDER
SET DCFILENAME=%APPDATA%\Roaming\doublecmd\doublecmd.xml
BANNERTEXT "Updating: %DCFILENAME%"

CALL :BACKUPFILE "%DCFILENAME%"
CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/Position/Left" "30"
CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/Position/Top" "30"
CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/Position/Width" "1840"
CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/Position/Height" "951"

REM CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/BestPosition/Left" "30"
REM CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/BestPosition/Top" "30"
REM CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/BestPosition/Width" "1840"
REM CALL :UPDATEXML "%DCFILENAME%" "/doublecmd/MainWindow/BestPosition/Height" "951"

GOTO :EOF


:NOTEPADPLUSPLUS
SET NPPFILENAME=%APPDATA%\Roaming\Notepad++\config.xml
BANNERTEXT "Updating: %NPPFILENAME%"

CALL :BACKUPFILE "%NPPFILENAME%"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@x" "60"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@y" "60"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@width" "1800"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@height" "930"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@width" "2440"
CALL :UPDATEXML "%NPPFILENAME%" "/NotepadPlus/GUIConfigs/GUIConfig[@name='AppPosition']/@height" "1280"

GOTO :EOF


:QUICKCALENDAR
PUSHD "%LOCALAPPDATA%\NRA_Systems_Limited"

FOR /F %%F in ('dir /s /b user.config') DO CALL :EDITQUICKCALENDAR %%F

GOTO :EOF


:EDITQUICKCALENDAR
SET QCFILENAME=%~1
BANNERTEXT "Updating: %QCFILENAME%"

CALL :BACKUPFILE "%QCFILENAME%"
CALL :UPDATEXML "%QCFILENAME%" "/configuration/userSettings/QuickCalendar.Properties.Settings/setting[@name='Main_Location']/value" "527, 235"
CALL :UPDATEXML "%QCFILENAME%" "/configuration/userSettings/QuickCalendar.Properties.Settings/setting[@name='Main_Size']/value" "1022, 575"

GOTO :EOF


:DONE
START TaskBarAlert /Type:BlueSky /Title:"%~n0" /Text:"Positions Restored" /TimeToStay:3000

GOTO :EOF


:BACKUPFILE
CALL CreateBackupFile.cmd "%~1" NUMBER

GOTO :EOF


:UPDATEXML
XML ed -L -u "%~2" -v "%~3" "%~1"

GOTO :EOF
