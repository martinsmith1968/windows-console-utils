@ECHO OFF

SETLOCAL

REM ***
REM ** 1) robocopy %USERPROFILE%\Downloads D:\ISO *.iso /z /mov /save:Downloads_ISO

SET JOBFOLDER=%USERPROFILE%

FOR %%F IN (%JOBFOLDER%\*.rcj) DO (
  BANNERTEXT "ROBOCOPY: %%~F"
  ROBOCOPY /JOB:%%~F
)
