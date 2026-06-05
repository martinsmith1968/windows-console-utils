@ECHO OFF

REM **********************************************************************
REM ** TODO
REM **
REM ** - Partial match shouldn't find first match but should show which
REM **   ones match if more than one
REM **********************************************************************


SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

FOR %%* IN (.) DO SET CURRENTDIR=%%~dpnx*
FOR %%* IN (.) DO SET CURRENTDIRNAME=%%~nx*

SET ARGPOS=0
SET DEBUG=N
SET USAGE=N
SET VERBOSE=Y

SET FORCE=N
SET FINDPARENT=N

SET NEWDIR=#
SET DELIM=#
SET MAXNAMELEN=40
SET MAXDESCLEN=60

CALL :UpCase SCRIPTNAME

SET DATAFILE=%LOCALAPPDATA%\%SCRIPTNAME%.dat
SET DATAFILEBACKUP=%LOCALAPPDATA%\%SCRIPTNAME%.dat.bak
CALL :DEBUG %DATAFILE%

IF NOT EXIST "%DATAFILE%" ( 
  COPY NUL "%DATAFILE%">NUL
)

SET TARGET=
SET COMMAND=LIST
SET ARG1=
SET ARG2=
SET ARG3=
SET ARG4=


:PARSE
IF "%~1" == "" GOTO :VALIDATE
IF /I "%~1" == "-?"     SET USAGE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/?"     SET USAGE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "?"      SET USAGE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "--HELP" SET USAGE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-X"     SET DEBUG=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/X"     SET DEBUG=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-V"     SET VERBOSE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/V"     SET VERBOSE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-V-"    SET VERBOSE=N&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/V-"    SET VERBOSE=N&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-F"     SET FORCE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/F"     SET FORCE=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "-P"     SET FINDPARENT=Y&&SHIFT && GOTO :PARSE
IF /I "%~1" == "/P"     SET FINDPARENT=Y&&SHIFT && GOTO :PARSE

SET /A ARGPOS+=1

IF %ARGPOS% EQU 1 SET COMMAND=%~1&& SHIFT && GOTO :PARSE
IF %ARGPOS% EQU 2 SET ARG1=%~1&& SHIFT && GOTO :PARSE
IF %ARGPOS% EQU 3 SET ARG2=%~1&& SHIFT && GOTO :PARSE
IF %ARGPOS% EQU 4 SET ARG3=%~1&& SHIFT && GOTO :PARSE

CALL :USAGE
CALL :ERROR "Unexpected argument at position %ARGPOS% : %~1"
GOTO :EOF


:VALIDATE
IF "%USAGE%" == "Y" CALL :USAGE && GOTO :EOF

IF /I "%COMMAND%" == "A"      SET TARGET=ADD
IF /I "%COMMAND%" == "ADD"    SET TARGET=ADD
IF /I "%COMMAND%" == "NEW"    SET TARGET=ADD
IF /I "%COMMAND%" == "CLEAN"  SET TARGET=CLEAN
IF /I "%COMMAND%" == "D"      SET TARGET=DELETE
IF /I "%COMMAND%" == "DEL"    SET TARGET=DELETE
IF /I "%COMMAND%" == "DELETE" SET TARGET=DELETE
IF /I "%COMMAND%" == "REM"    SET TARGET=DELETE
IF /I "%COMMAND%" == "REMOVE" SET TARGET=DELETE
IF /I "%COMMAND%" == "GOTO"   SET TARGET=GOTO
IF /I "%COMMAND%" == "L"      SET TARGET=LIST
IF /I "%COMMAND%" == "LIST"   SET TARGET=LIST
IF /I "%COMMAND%" == "VIEW"   SET TARGET=LIST
IF /I "%COMMAND%" == "SET"    SET TARGET=SET
IF /I "%COMMAND%" == "CHANGE" SET TARGET=SET
IF /I "%COMMAND%" == "W"      SET TARGET=WHERE
IF /I "%COMMAND%" == "WHERE"  SET TARGET=WHERE
IF /I "%COMMAND%" == "EXPORT" SET TARGET=EXPORT
IF /I "%COMMAND%" == "NPP"    SET TARGET=NPP
IF /I "%COMMAND%" == "LOCAL"  SET TARGET=CUSTOMISELOCAL&& SET ARG1=%CD%
IF /I "%COMMAND%" == "."      SET TARGET=CUSTOMISELOCAL&& SET ARG1=%CD%

IF "%TARGET%" == "" (
    IF "%COMMAND%" == "" (
        SET TARGET=LIST
    ) ELSE (
        SET ARG4=%ARG3%
        SET ARG3=%ARG2%
        SET ARG2=%ARG1%
        SET ARG1=%COMMAND%
        SET TARGET=GOTO
    )
)

CALL :DEBUG "COMMAND = %COMMAND%"
CALL :DEBUG "ARG1 = %ARG1%"
CALL :DEBUG "ARG2 = %ARG2%"
CALL :DEBUG "ARG3 = %ARG3%"
CALL :DEBUG "ARG4 = %ARG4%"
CALL :DEBUG "TARGET = %TARGET%"


:GO
CALL :%TARGET% %ARG1% %ARG2% %ARG3% %ARG4%
CALL :DEBUG "NEWDIR = %NEWDIR%"

ENDLOCAL && SET FAVDIR=%NEWDIR%

IF NOT "%FAVDIR%" == "#" (
    CALL :CHANGEDIR "%FAVDIR%"
)

SET FAVDIR=

GOTO :EOF


:USAGE
CALL :SHOWHEADER
ECHO.Usage:
ECHO.%SCRIPTNAME% [command] {options}
ECHO.
ECHO.Commands:
ECHO. LIST                              - List favourite folders
ECHO. ADD { [alias-name] { [folder] } } - Add a favourite folder with the specified alias and folder. If alias is not supplied the current folder name is used. If folder is not supplied the current folder is used.
ECHO. SET { [alias-name] { [folder] } } - Add a favourite folder with the specified alias and folder. If alias is not supplied the current folder name is used. If folder is not supplied the current folder is used.
ECHO. DELETE [alias-name]               - Delete a favourite folder with the specified alias. If alias is not supplied the current folder name is used.
ECHO. WHERE {folder}                    - Show the alias for the specified folder. If folder is not supplied the current folder is used.
ECHO. EXPORT                            - Export the favourite folders to the console
ECHO. CLEAN                             - Remove any non-existent folders from the list
ECHO. NPP                               - Open the favourite folders in Notepad++
ECHO.
ECHO.add - add a favourite folder
ECHO.E.g. %SCRIPTNAME% add {alias-name} [ {folder} ] 
ECHO.     If {folder} is not supplied the current location is used
ECHO.
ECHO.del - delete a favourite folder
ECHO.E.g. %SCRIPTNAME% del {alias-name}
ECHO.
ECHO.list - list favourite folders
ECHO.E.g. %SCRIPTNAME% list
ECHO.
CALL :SHOWDATAFILENAME

IF NOT "%~1" == "" (
    CALL :ERROR: "%~1"
)

GOTO :EOF


:ERROR
ECHO.
ECHO.ERROR: %~1

GOTO :EOF


:DEBUG
IF "%DEBUG%" == "Y" (
    ECHO.DEBUG: %~1
)

GOTO :EOF


:GOTO
CALL :FINDBYEXACTNAME "%~1"
IF "%FOUND%" == "Y" (
    SET NEWDIR=%FINDTARGET%
    GOTO :EOF
)

CALL :FINDBYPARTIALNAME "%~1" "%~2"
IF "%FOUND%" == "Y" (
    SET NEWDIR=%FINDTARGET%
    GOTO :EOF
)

CALL :ERROR "Alias '%~1' does not exist or cannot be matched"
GOTO :EOF


:CHANGEDIR
IF "%VERBOSE%" == "Y" ECHO.Changing to: %~1
CD /D %~1

CALL :CUSTOMISE

IF NOT "%~2" == "" (
    IF NOT EXIST "%~2\*.*" (
        CALL :DEBUG "Subdir not found : %~2"
        GOTO :EOF
    )
    
    CALL :CHANGEDIR "%~2" "%~3" "%~4"
)

GOTO :EOF


:CUSTOMISE
IF EXIST "%~dp0\.fav.cmd" (
    IF "%VERBOSE%" == "Y" ECHO.Customising via global .fav.cmd ...
    CALL "%~dp0\.fav.cmd"
)

CALL :CUSTOMISELOCAL "%CD%" N

GOTO :EOF


:CUSTOMISELOCAL
SET LOCALFILEPATH=%~dpnx1
SET RELATIVEFILEPATH=%~p1
SET FINDPARENT=%~2

IF "%RELATIVEFILEPATH%" == "\" (
    IF "%FINDPARENT%" == "Y" (
        GOTO :EOF
    )
)

SET LOCALFILENAME=%LOCALFILEPATH%\.fav.cmd

SET LOCALFILENAMEDISPLAY=%LOCALFILENAME%
IF "%FINDPARENT%" == "N" SET LOCALFILENAMEDISPLAY=.fav.cmd

IF EXIST "%LOCALFILENAME%" (
    IF "%VERBOSE%" == "Y" ECHO.Customising via local %LOCALFILENAMEDISPLAY% ...
    PUSHD "%LOCALFILEPATH%"
    CALL "%LOCALFILENAME%"
    POPD
    SET FINDPARENT=N
)

IF "%FINDPARENT%" == "N" GOTO :EOF

CALL :CUSTOMISELOCAL "%LOCALFILEPATH%\.." Y

GOTO :EOF


:ADD
SET ALIAS=%1
SET DIR=%2

IF "%ALIAS%" == "" (
    SET ALIAS=!CURRENTDIRNAME!
)
IF "%DIR%" == "" (
    SET DIR=!CURRENTDIR!
)

IF "%ALIAS%" == "" (
    CALL :USAGE "Alias not specified"
    GOTO :EOF
)

CALL :CHECKEXISTS %ALIAS%
IF "%EXISTS%" == "Y" (
    IF "%FORCE%" == "N" (
        CALL :ERROR "Alias '%ALIAS%' already exists - use SET or /F to replace"
        GOTO :EOF
    )
    IF "%VERBOSE%" == "Y" ECHO.Alias '%ALIAS%' already exists - replacing
)

CALL :UpCase ALIAS

ECHO.%ALIAS%%DELIM%%DIR%>>"%DATAFILE%"
CALL :REORDER

IF "%VERBOSE%" == "Y" ECHO.%ALIAS% Added - %DIR%

GOTO :EOF


:CLEAN
ECHO.TODO: Not Yet Implemented
REM Get list of all aliases and targets
REM Iterate and build list of those that don't exist
REM Iterate over new list and call :DELETE for each
REM Report summary
GOTO :EOF


:DELETE
SET ALIAS=%1
IF "%ALIAS%" == "" (
    CALL :USAGE "Alias not specified"
    GOTO :EOF
)

CALL :CHECKEXISTS %ALIAS%
IF "%EXISTS%" == "N" (
    CALL :ERROR "Alias '%ALIAS%' does not exist"
    GOTO :EOF
)

CALL :UpCase ALIAS

FINDSTR /v /b "%ALIAS%%DELIM%" "%DATAFILE%" > "%DATAFILEBACKUP%"
CALL :RESTOREDATA
CALL :REORDER

IF "%VERBOSE%" == "Y" ECHO.%ALIAS% Deleted

GOTO :EOF


:VIEW
:LIST
:SHOW
CALL :SHOWHEADER
CALL :SHOWDATAFILENAME

SET UNDERLINE1=
FOR /L %%I IN (1, 1, %MAXNAMELEN%) DO SET UNDERLINE1=!UNDERLINE1!-

SET UNDERLINE2=
FOR /L %%I IN (1, 1, %MAXDESCLEN%) DO SET UNDERLINE2=!UNDERLINE2!-

CALL :SHOWITEM "Alias" "Directory" "#"
ECHO.%UNDERLINE1% - %UNDERLINE2%
FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :SHOWALIAS "%%A" "%%B"
)

GOTO :EOF


:WHERE
SET TARGET=%~1
IF "%TARGET%" == "" SET TARGET=%CD%

CALL :FINDBYEXACTTARGET "%TARGET%"
IF "%FOUND%" == "Y" (
    GOTO :EOF
)

IF "%FINDPARENT%" == "Y" (
    CALL :DEBUG "Exact target not found, trying parent folders..."
    CALL :FINDBYPARTIALTARGET "%TARGET%"
    IF "%FOUND%" == "Y" (
        GOTO :EOF
    )
)

CALL :ERROR "Directory not found : %TARGET%"
GOTO :EOF


:SHOWALIAS
SET INDICATOR=
IF NOT EXIST "%~2\*.*" (
    SET INDICATOR=#
)

CALL :SHOWITEM "%~1" "%~2" "%INDICATOR%"

GOTO :EOF


:SHOWITEM
PRINTFORMAT "{0,-%MAXNAMELEN%} {1,1} {2}" "%~1" "%~3" "%~2 "

GOTO :EOF


:CHECKEXISTS
SET EXISTS=N
FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :DEBUG "%%A - %%B"
    IF /I "%%A" == "%~1" (
        SET EXISTS=Y
    )
)

GOTO :EOF


:FINDBYEXACTNAME
SET FOUND=N
SET FINDALIAS=
SET FINDTARGET=
FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :DEBUG "%%A - %%B"
    IF /I "%%A" == "%~1" (
        IF "%VERBOSE%" == "Y" ECHO.Found: %%A - %%B
        
        SET FOUND=Y
        SET FINDALIAS=%%A
        SET FINDTARGET=%%B

        GOTO :EOF
    )
)

GOTO :EOF


:FINDBYPARTIALNAME
SET FOUND=N
SET FINDALIAS=
SET FINDTARGET=
SET MATCHCOUNT=0
SET TARGETINDEX=

CALL :ISNUMERIC "%~2"
IF "%ISNUMERIC%" == "Y" (
    SET TARGETINDEX=%~2
)

FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :DEBUG "%%A - %%B"
    IF NOT "%TARGETINDEX%" == "" (

    )
    CALL :DOESSTARTWITH "%%A" "%~1"
    IF "!STARTSWITH!" == "Y" (
        IF "%VERBOSE%" == "Y" ECHO.Matched: %%A - %%B
        
        SET /A MATCHCOUNT += 1
        SET FINDALIAS=%%A
        SET FINDTARGET=%%B
    ) ELSE (
        CALL :DOESCONTAIN "%%A" "%~1"
        IF "!CONTAINS!" == "Y" (
            IF "%VERBOSE%" == "Y" ECHO.Matched: %%A - %%B
            
            SET /A MATCHCOUNT += 1
            SET FINDALIAS=%%A
            SET FINDTARGET=%%B
        )
    )
)

IF "%TARGETINDEX%" == "%MATCH%"
IF %MATCHCOUNT% EQU 1 (
    SET FOUND=Y
)

GOTO :EOF


:FINDBYEXACTTARGET
SET FOUND=N
SET FINDALIAS=
SET FINDTARGET=
FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :DEBUG "%%A - %%B"
    IF /I "%%B" == "%~1" (
        IF "%VERBOSE%" == "Y" ECHO.Found: %%A - %%B
        
        SET FOUND=Y
        SET FINDALIAS=%%A
        SET FINDTARGET=%%B

        GOTO :EOF
    )
)

GOTO :EOF


:DOESSTARTWITH
SET STARTSWITH=N

CALL :strlen "%~2" MATCHLEN

SET TEXT=%~1
SET PREFIX=!TEXT:~0,%MATCHLEN%!

IF /I "%PREFIX%" == "%~2" (
    SET STARTSWITH=Y
)

GOTO :EOF


:DOESCONTAIN
SET CONTAINS=N

SET SOURCE=%~1
SET TARGET=%~2

ECHO.%SOURCE% | FINDSTR /I /C:"%TARGET%" 1>nul
IF NOT ERRORLEVEL 1 SET CONTAINS=Y

GOTO :EOF


:ISNUMERIC
SET ISNUMERIC=N

SET VALUE=%~1
SET /A VALUE+=1

IF %VALLUE% GTR 0 SET ISNUMERIC=Y

GOTO :EOF

:BACKUPDATA
COPY /Y "%DATAFILE%" "%DATAFILEBACKUP%">NUL

GOTO :EOF


:RESTOREDATA
IF NOT EXIST "%DATAFILEBACKUP%" GOTO :EOF

COPY /Y "%DATAFILEBACKUP%" "%DATAFILE%">NUL

GOTO :EOF


:REORDER
SORT "%DATAFILE%" /O "%DATAFILE%"

GOTO :EOF


:SET
SET ALIAS=%1
SET DIR=%2
IF "%DIR%" == "" (
    SET DIR=!CD!
)

IF "%ALIAS%" == "" (
    CALL :USAGE "Alias not specified"
    GOTO :EOF
)

CALL :DELETE "%ALIAS%"
CALL :ADD    "%ALIAS%" "%DIR%"
CALL :REORDER

GOTO :EOF


:EXPORT
IF EXIST "%DATAFILE%" (
    TYPE "%DATAFILE%"
)

GOTO :EOF


:NPP
IF EXIST "%DATAFILE%" (
    CALL NPP.CMD "%DATAFILE%"
)

GOTO :EOF


:SHOWHEADER
CALL "%SCRIPTPATH%\GetDateTime.cmd"

ECHO.%SCRIPTNAME% - Control favourite folders
ECHO.(c) Martin Smith 2013-%CURRENTDATETIME_YEAR%
ECHO.

GOTO :EOF


:SHOWDATAFILENAME
ECHO.DataFile: %DATAFILE%
ECHO.

GOTO :EOF


:LoCase
:: Subroutine to convert a variable VALUE to all lower case.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF


:UpCase
:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF


:TCase
:: Subroutine to convert a variable VALUE to Title Case.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN (" a= A" " b= B" " c= C" " d= D" " e= E" " f= F" " g= G" " h= H" " i= I" " j= J" " k= K" " l= L" " m= M" " n= N" " o= O" " p= P" " q= Q" " r= R" " s= S" " t= T" " u= U" " v= V" " w= W" " x= X" " y= Y" " z= Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF


:strlen string len
SET "token=#%~1" & SET "len=0"
FOR /L %%A IN (12,-1,0) DO (
    SET /A "len|=1<<%%A"
    FOR %%B IN (!len!) DO IF "!token:~%%B,1!"=="" SET /A "len&=~1<<%%A"
)
SET %~2=%len%
