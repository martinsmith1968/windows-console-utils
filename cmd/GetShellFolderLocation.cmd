@if (@CodeSection == @Batch) @then
@ECHO OFF & SETLOCAL

IF "%~1" == "" ECHO.Usage: %~n0 [shell-folder-name] && GOTO :EOF

CALL :GETSPECIALFOLDER %~1 FolderLocation

ECHO.%FolderLocation%

GOTO :EOF

:GETSPECIALFOLDER <folderName=returnValue>
FOR /f "delims=" %%I IN ('cscript /nologo /e:JScript "%~f0" "%~1"') DO SET "%~2=%%I"
GOTO :EOF

@end // end batch begin JScript
WSH.Echo(WSH.CreateObject('WScript.Shell').SpecialFolders(WSH.Arguments(0)));
