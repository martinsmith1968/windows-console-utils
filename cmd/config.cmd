@ECHO OFF

REM **********************************************************************
REM ** DESCRIPTION: Configure the current command environment
REM **
REM ** Needs GnuUtils installed in order to work:
REM ** - GREP
REM ** - SED
REM **********************************************************************

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0


SET DEBUGON=Y
SET DEBUGON=N

IF "%~1" == "" (
    CALL :_USAGE
    GOTO :EOF
)

SET CONFIGNAME=%~1
SET NEWTITLE=%CONFIGNAME%

ENDLOCAL && CALL :%CONFIGNAME% %2
REM ECHO.%NEWTITLE%

GOTO :EOF


REM ********************************************************************************
:NONE               -- CLEAR ENVIRONMENT
COLOR 07

SET NEWTITLE=%CD%

GOTO :EOF


REM ********************************************************************************
:VS2010             -- VISUAL STUDIO 2012 .NET COMMAND PROMPT
IF "%~1" == "64" (
    CALL "c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64
) ELSE (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
)

COLOR 17

GOTO :EOF


REM ********************************************************************************
:VS2012             -- VISUAL STUDIO 2012 .NET COMMAND PROMPT
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\Tools\VsDevCmd.bat"

COLOR 17

GOTO :EOF


REM ********************************************************************************
:VS2013             -- VISUAL STUDIO 2013 .NET COMMAND PROMPT
IF EXIST "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat" (
    CALL "D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
) ELSE (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
)

COLOR 17

GOTO :EOF


REM ********************************************************************************
:VS2015             -- VISUAL STUDIO 2015 .NET COMMAND PROMPT
IF EXIST "D:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat" (
    CALL "D:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat"
) ELSE (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat"
)

COLOR 17

GOTO :EOF


REM ********************************************************************************
:VS2017             -- VISUAL STUDIO 2017 .NET AND TOOLS COMMAND PROMPT
PUSHD .
IF EXIST "D:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat" (
    CALL "D:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat"
) ELSE (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat"
)
POPD

COLOR 17

GOTO :EOF


REM ********************************************************************************
:VS2019             -- VISUAL STUDIO 2019 .NET AND TOOLS COMMAND PROMPT
PUSHD .
IF EXIST "D:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat" (
    CALL "D:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat"
) ELSE (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat"
)
POPD

COLOR 17

GOTO :EOF


REM ********************************************************************************
:SQLDAC             -- SQL SERVER DACPAC
CALL :_ADDPATHIFEXISTS "C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin"
CALL :_ADDPATHIFEXISTS "C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin"
CALL :_ADDPATHIFEXISTS "C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin"
CALL :_ADDPATHIFEXISTS "C:\Program Files (x86)\Microsoft SQL Server\100\DAC\bin"

GOTO :EOF


REM ********************************************************************************
:SQLDAC120          -- SQL SERVER DACPAC v12
CALL :_ADDPATHIFEXISTS "C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin"

GOTO :EOF


REM ********************************************************************************
:MYSQL56
CALL :_ADDPATHIFEXISTS "c:\xampp\mysql\bin"
CALL :_ADDPATHIFEXISTS "c:/wamp/bin/mysql/mysql5.6.12/bin"
CALL :_ADDPATHIFEXISTS "c:/wamp/bin/mysql/mysql5.5.24/bin"

PATHLIST

GOTO :EOF


REM ********************************************************************************
:NODE
CALL "C:\Program Files\nodejs\nodevars.bat"

GOTO :EOF


REM ********************************************************************************
:PYTHON
CALL :PYTHON2

GOTO :EOF


REM ********************************************************************************
:PYTHON2
CALL :_ADDPATHIFEXISTS "C:\Python27"
CALL :_ADDPATHIFEXISTS "D:\Python27"

PATHLIST

GOTO :EOF


REM ********************************************************************************
:PYTHON3
CALL :_ADDPATHIFEXISTS "C:\Python35"
CALL :_ADDPATHIFEXISTS "D:\Python35"
CALL :_ADDPATHIFEXISTS "C:\Python34"
CALL :_ADDPATHIFEXISTS "D:\Python34"

PATHLIST

GOTO :EOF


REM ********************************************************************************
:ANGULAR
CALL :_ADDPATHIFEXISTS "%USERPROFILE%\AppData\Roaming\npm"

PATHLIST

GOTO :EOF


REM ********************************************************************************
:_HEADER
ECHO.%SCRIPTNAME% - Configure command line environment
ECHO.

GOTO :EOF


REM ********************************************************************************
:_USAGE
CALL :_HEADER
ECHO.Usage:
ECHO.%SCRIPTNAME% config-name [ options ]
ECHO.

CALL :_LISTLABELS

GOTO :EOF

REM ********************************************************************************
:_ADDPATHIFEXISTS
IF NOT EXIST "%~1\*.*" (
    GOTO :EOF
)

SET PATH=%PATH%;%~1

GOTO :EOF


REM ********************************************************************************
:_LISTLABELS
GREP "^[ \t]*:" "%SCRIPTFULLFILENAME%" | GREP -v "^[ \t]*:_" | SED -e "s/^://g"

GOTO :EOF


REM ********************************************************************************
:_PARSEPATHNAME
SET PARSEDPATH=%~n1
GOTO :EOF
