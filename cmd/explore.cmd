@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpn*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~n*

SET ARGPOS=0
SET DEBUG=N
SET DRYRUN=N
SET USAGE=N

SET COMMANDPREFIX=

SET VERBOSE=Y
SET SHELLTARGET=
SET SHELLSOURCE=
SET TARGET=.
SET EXTRA=

REM Source : https://ss64.com/nt/shell.html
SET ALIASTARGETS1=startup:startup:common startup
SET ALIASTARGETS2=startmenu:start menu:common start menu
SET ALIASTARGETS3=programs:programs:common programs
SET ALIASTARGETS4=desktop:desktop:common desktop
SET ALIASTARGETS5=appdata:appdata:common appdata
SET ALIASTARGETS6=localappdata:local appdata:
SET ALIASTARGETS7=music:My Music:CommonMusic
SET ALIASTARGETS8=pictures:PicturesLibrary:CommonPictures
REM TODO: Add more known targets as needed

REM **********************************************************************
REM ** Guides
REM ** - Variable Substring : https://ss64.com/nt/syntax-substring.html
REM **********************************************************************


:PARSE
IF "%~1" == "" GOTO :VALIDATE

IF /I "%~1" == "/?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-?" SET USAGE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-X" SET DEBUG=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-Z" SET DRYRUN=Y&&SHIFT&&GOTO :PARSE

IF /I "%~1" == "/v"    SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-v"    SET VERBOSE=Y&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/v-"   SET VERBOSE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-v-"   SET VERBOSE=N&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/t"    SET SHELLTARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-t"    SET SHELLTARGET=%~2&&SHIFT&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tst"  SET SHELLTARGET=startup&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tst"  SET SHELLTARGET=startup&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tsm"  SET SHELLTARGET=startmenu&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tsm"  SET SHELLTARGET=startmenu&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tp"   SET SHELLTARGET=programs&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tp"   SET SHELLTARGET=programs&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/td"   SET SHELLTARGET=desktop&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-td"   SET SHELLTARGET=desktop&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tad"  SET SHELLTARGET=appdata&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tad"  SET SHELLTARGET=appdata&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tlad" SET SHELLTARGET=localappdata&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tlad" SET SHELLTARGET=localappdata&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/tap"  SET SHELLTARGET=appsfolder&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-tap"  SET SHELLTARGET=appsfolder&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/c"    SET SHELLSOURCE=common&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-c"    SET SHELLSOURCE=common&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/p"    SET SHELLSOURCE=common&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-p"    SET SHELLSOURCE=common&&SHIFT&&GOTO :PARSE

REM Source : https://ss64.com/nt/explorer.html
IF /I "%~1" == "/n"   SET EXTRA=%EXTRA% /n&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-n"   SET EXTRA=%EXTRA% /n&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "/np"  SET EXTRA=%EXTRA% /separate&&SHIFT&&GOTO :PARSE
IF /I "%~1" == "-np"  SET EXTRA=%EXTRA% /separate&&SHIFT&&GOTO :PARSE

SET /A ARGPOS+=1
IF %ARGPOS% EQU 1 SET TARGET=%~1&&SHIFT&&GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unknown argument at position: %ARGPOS% - %~1"
GOTO :EOF


:VALIDATE
CALL :SET_TARGET_FROM_ALIAS "%SHELLTARGET%" "%SHELLSOURCE%"
IF "%TARGET%" == "" SET USAGE=Y

IF "%USAGE%" == "Y" (
    CALL :USAGE
    GOTO :EOF
)

:GO
IF "%DEBUG%" == "Y" (
    ECHO.ARGPOS      = %ARGPOS%
    ECHO.DRYRUN      = %DRYRUN%
    ECHO.DEBUG       = %DEBUG%
    ECHO.SHELLTARGET = %SHELLTARGET%
    ECHO.SHELLSOURCE = %SHELLSOURCE%
    ECHO.TARGET      = %TARGET%
)

IF "%DRYRUN%" == "Y" SET COMMANDPREFIX=ECHO.

IF "%VERBOSE%" == "Y" (
    %COMMANDPREFIX%ECHO.Opening Explorer at: %TARGET%
)
@IF "%DEBUG%" == "Y" @ECHO ON
%COMMANDPREFIX%explorer "%TARGET%" %EXTRA%
@IF "%DEBUG%" == "Y" @ECHO OFF

GOTO :EOF


:SET_TARGET_FROM_ALIAS
IF "%~1" == "" GOTO :EOF

IF "%DEBUG%" == "Y" @ECHO.Setting target from alias targets: %~1 %~2

SET INDEX=1
:SET_TARGET_FROM_ALIAS_LOOP
SET ALIAS=!ALIASTARGETS%INDEX%!
IF "%ALIAS%" == "" (
    SET TARGET=shell:%~1
    GOTO :EOF
)

FOR /F "tokens=1,2,3 delims=:" %%A IN ("!ALIAS!") DO (
    IF "%DEBUG%" == "Y" @ECHO.Found : %%A : %%B : %%C
    IF /I "%%A" == "%~1" (
        IF /I "%~2" == "common" (
            SET TARGET=shell:%%C
        ) ELSE (
            SET TARGET=shell:%%B
        )
        GOTO :EOF
    )
)

SET /A INDEX+=1
GOTO :SET_TARGET_FROM_ALIAS_LOOP

GOTO :EOF


:USAGE
ECHO.%SCRIPTNAME% - Open Explorer in a specified path
ECHO.
ECHO.Usage: %SCRIPTNAME% [target-directory] { [options] }
ECHO.
ECHO.Options:
ECHO. /t [name] - Named Shell Target (See Notes)
ECHO. /c        - Use the Common / Public version of the Shell Target
ECHO. /n        - Use a New Explorer Window
ECHO. /tst      - Shortcut for : /t startup
ECHO. /tsm      - Shortcut for : /t startmenu
ECHO. /tp       - Shortcut for : /t programs
ECHO. /td       - Shortcut for : /t desktop
ECHO. /tad      - Shortcut for : /t appdata
ECHO. /tlad     - Shortcut for : /t localappdata
ECHO. /tap      - Shortcut for : /t appsfolder
ECHO.
ECHO.Notes:
ECHO. See: https://ss64.com/nt/shell.html for a list of known Shell Targets that can be used with the /t option.
ECHO.
ECHO.The following aliases also exist :

SET INDEX=1
:DISPLAY_ALIAS_LOOP
SET ALIAS=!ALIASTARGETS%INDEX%!
IF "%ALIAS%" == "" GOTO :EOF

FOR /F "tokens=1,2,3 delims=:" %%A IN ("!ALIAS!") DO (
    ECHO. %%A : User: %%B [Common: %%C]
)

SET /A INDEX+=1
GOTO :DISPLAY_ALIAS_LOOP

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
