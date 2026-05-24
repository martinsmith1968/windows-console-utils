@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET ARGPOS=0
SET DEBUG=N
SET DRYRUN=N
SET USAGE=N

SET MACROFILENAME=%~dp0\doskey.mac
SET QUIET=N
SET COMMAND=list

IF /I "%DOSKEY_MAC%" == "HIDE" (
  SET QUIET=Y
)

:PARSE
IF "%~1" == "" GOTO :VALIDATE

IF /I "%~1" == "/?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/Q" SET QUIET=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Q" SET QUIET=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Q-" SET QUIET=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Q-" SET QUIET=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/F" SET MACROFILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-F" SET MACROFILENAME=%~2&&SHIFT&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET COMMAND=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
IF "%COMMAND%" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
  CALL :USAGE
  GOTO :EOF
)


:GO
IF /I "%COMMAND%" == "LIST" GOTO :LIST
IF /I "%COMMAND%" == "INSTALL" GOTO :INSTALL
IF /I "%COMMAND%" == "NPP" GOTO :NPP

CALL :ERROR "Unknown or unsupported command: %COMMAND%"
GOTO :EOF


:LIST
DOSKEY /MACROS

GOTO :EOF


:INSTALL
IF NOT EXIST "%MACROFILENAME%" (
    CALL :ERROR "Macro file not found: %MACROFILENAME%"
    GOTO :EOF
)   

IF "%QUIET%" == "N" (
    ECHO.Installing aliases : %MACROFILENAME%...
)   
@%SYSTEMROOT%\System32\DOSKEY /MACROFILE=%MACROFILENAME%

GOTO :EOF


:NPP
IF NOT EXIST "%MACROFILENAME%" (
    CALL :ERROR "Macro file not found: %MACROFILENAME%"
    GOTO :EOF
)   

IF "%QUIET%" == "N" (
    ECHO.Editing: %MACROFILENAME%...
)   
CALL npp.cmd %MACROFILENAME%

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Manage command aliases
ECHO.
ECHO.Usage: %SCRIPTNAME% [command] { [options] }
ECHO.
ECHO.Commands
ECHO.   LIST    - List all current defined aliases
ECHO.   INSTALL - Install aliases from a macro file
ECHO.   NPP     - Edit macro definitions file in Notepad++
ECHO.
ECHO.Options:
ECHO. /F [filename] - Specify the macro file to use

GOTO :EOF


:ERROR
SET ERROTEXT=
:ERRORLOOP
IF NOT "%~1" == "" (
  SET ERRORTEXT=%ERRORTEXT% %~1
  SHIFT
  GOTO :ERRORLOOP
)
ECHO.ERROR:%ERRORTEXT%
GOTO :EOF
