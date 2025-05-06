@ECHO OFF

REM **********************************************************************
REM ** Needs GnuUtils installed in order to work:
REM ** - PRINTF
REM ** - SED
REM **********************************************************************

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

SET DEBUGON=N
REM SET DEBUGON=Y

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

SET TARGET=#
SET ARG1=%~2
SET ARG2=%~3
SET ARG3=%~4

IF /I "%~1" == "ADD"    SET TARGET=ADD
IF /I "%~1" == "DEL"    SET TARGET=DELETE
IF /I "%~1" == "DELETE" SET TARGET=DELETE
IF /I "%~1" == "REM"    SET TARGET=DELETE
IF /I "%~1" == "REMOVE" SET TARGET=DELETE
IF /I "%~1" == "VIEW"   SET TARGET=LIST
IF /I "%~1" == "LIST"   SET TARGET=LIST
IF /I "%~1" == "L"      SET TARGET=LIST
IF /I "%~1" == "SET"    SET TARGET=SET
IF /I "%~1" == "?"      SET TARGET=USAGE
IF /I "%~1" == "-?"     SET TARGET=USAGE
IF /I "%~1" == "/?"     SET TARGET=USAGE
IF /I "%~1" == "--HELP" SET TARGET=USAGE
IF /I "%~1" == "EXPORT" SET TARGET=EXPORT
IF /I "%~1" == "NPP"    SET TARGET=NPP
IF /I "%~1" == "LOCAL"  SET TARGET=CUSTOMISELOCAL && SET ARG1=%CD%
IF /I "%~1" == "."      SET TARGET=CUSTOMISELOCAL && SET ARG1=%CD%

IF "%TARGET%" == "#" (
    IF NOT "%~1" == "" (
        SET TARGET=GOTO
        SET ARG1=%~1
        SET ARG2=%~2
        SET ARG3=%~3
    ) ELSE (
        SET TARGET=LIST
    )
)

CALL :%TARGET% %ARG1% %ARG2% %ARG3%

CALL :DEBUG "NEWDIR = %NEWDIR%"

ENDLOCAL && SET FAVDIR=%NEWDIR%

IF NOT "%FAVDIR%" == "#" (
    CALL :CHANGEDIR "%FAVDIR%"
)

SET FAVDIR=

GOTO :EOF


:GOTO
CALL :FINDBYEXACTNAME "%~1"
IF "%FOUND%" == "Y" (
    SET NEWDIR=%FINDTARGET%
    GOTO :EOF
)

CALL :FINDBYPARTIALNAME "%~1"
IF "%FOUND%" == "Y" (
    SET NEWDIR=%FINDTARGET%
    GOTO :EOF
)

CALL :ERROR "Alias '%~1' does not exist or cannot be matched"
GOTO :EOF


:CHANGEDIR
ECHO.Changing to: %~1
CD /D %~1

CALL :CUSTOMISE

IF NOT "%~2" == "" (
    IF NOT EXIST "%~2\*.*" (
        ECHO.Subdir not found : %~2
        GOTO :EOF
    )
    
    CALL :CHANGEDIR "%~2" "%~3" "%~4"
)

GOTO :EOF


:CUSTOMISE
IF EXIST "%~dp0\.fav.cmd" (
    ECHO.Customising via global .fav.cmd ...
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
    ECHO.Customising via local %LOCALFILENAMEDISPLAY% ...
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
    CALL :ERROR "Alias '%ALIAS%' already exists - use SET to replace"
    GOTO :EOF
)

CALL :UpCase ALIAS

ECHO.%ALIAS%%DELIM%%DIR%>>"%DATAFILE%"
CALL :REORDER

ECHO.%ALIAS% Added - %DIR%

GOTO :EOF


:DEL
:DELETE
:REM
:REMOVE
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

SED -e "/^%ALIAS%%DELIM%/d" "%DATAFILE%" > "%DATAFILEBACKUP%"
CALL :RESTOREDATA
CALL :REORDER

ECHO.%ALIAS% Deleted

GOTO :EOF


:VIEW
:LIST
:SHOW
CALL :HEADER

CALL :SHOWITEM "DataFile: %DATAFILE%"
CALL :SHOWITEM ""

SET UNDERLINE1=
FOR /L %%I IN (1, 1, %MAXNAMELEN%) DO SET UNDERLINE1=!UNDERLINE1!-

SET UNDERLINE2=
FOR /L %%I IN (1, 1, %MAXDESCLEN%) DO SET UNDERLINE2=!UNDERLINE2!-

CALL :SHOWITEM "Alias" "Directory" "#"
CALL :SHOWITEM "%UNDERLINE1%" "%UNDERLINE2%" "-"
FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :SHOWALIAS "%%A" "%%B"
)

GOTO :EOF


:SHOWALIAS
SET INDICATOR=
IF NOT EXIST "%~2\*.*" (
    SET INDICATOR=#
)

CALL :SHOWITEM "%~1" "%~2" "%INDICATOR%"

GOTO :EOF


:SHOWITEM
PRINTF "%%-%MAXNAMELEN%s %%1s %%s\n" "%~1" "%~3" "%~2 "

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
        ECHO.Found: %%A - %%B
        
        SET FOUND=Y
        SET FINDALIAS=%%A
        SET FINDTARGET=%%B

        GOTO :EOF
    )
)

GOTO :EOF


:FINDBYPARTIALNAME
SET FOUND=0
SET FINDALIAS=
SET FINDTARGET=

FOR /F "usebackq tokens=1,2* delims=%DELIM%" %%A IN ("%DATAFILE%") DO (
    CALL :DEBUG "%%A - %%B"
    
    CALL :DOESSTARTWITH "%%A" "%~1"
    IF "!STARTSWITH!" == "Y" (
        ECHO.Matched: %%A - %%B
        
        SET /A FOUND += 1
        SET FINDALIAS=%%A
        SET FINDTARGET=%%B
    ) ELSE (
        CALL :DOESCONTAIN "%%A" "%~1"
        IF "!CONTAINS!" == "Y" (
            ECHO.Matched: %%A - %%B
            
            SET /A FOUND += 1
            SET FINDALIAS=%%A
            SET FINDTARGET=%%B
        )
    )
)

IF %FOUND% EQU 1 (
    SET FOUND=Y
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


:HEADER
CALL "%SCRIPTPATH%\GetDateTime.cmd"

ECHO.%SCRIPTNAME% - Control favourite folders
ECHO.(c) Martin Smith 2013-%CURRENTDATETIME_YEAR%
ECHO.

GOTO :EOF


:HELP
:USAGE
CALL :HEADER
ECHO.Usage:
ECHO.%SCRIPTNAME% [ add / del / set / list / export / npp / {alias-name} ] {options}
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
ECHO.DataFile: %DATAFILE%

IF NOT "%~1" == "" (
    CALL :ERROR: "%~1"
)

GOTO :EOF


:ERROR
ECHO.
ECHO.Error: %~1

GOTO :EOF


:DEBUG
IF "%DEBUGON%" == "Y" (
    ECHO.DEBUG: %~1
)

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
SETLOCAL EnableDelayedExpansion
SET "token=#%~1" & SET "len=0"
FOR /L %%A IN (12,-1,0) DO (
    SET /A "len|=1<<%%A"
    FOR %%B IN (!len!) DO IF "!token:~%%B,1!"=="" SET /A "len&=~1<<%%A"
)
ENDLOCAL & SET %~2=%len%
