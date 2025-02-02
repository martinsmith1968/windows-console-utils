@ECHO OFF

SETLOCAL

IF "%~1" == "" (
    CALL :USAGE
    GOTO :EOF
)

pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org "%~1"

GOTO :EOF


:USAGE
ECHO.%~n0 - pip install a module allowing for ZScaler, etc
ECHO.
ECHO.%~n0 [module]

GOTO :EOF
