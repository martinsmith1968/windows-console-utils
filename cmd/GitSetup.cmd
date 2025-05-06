@ECHO OFF

SETLOCAL EnableDelayedExpansion

SET SCRIPTPATH=%~dp0
SET SCRIPTNAME=%~n0
SET SCRIPTFULLFILENAME=%~dpnx0

SET DEBUG=N
SET VERBOSE=N

SET REPOCOUNT=0
SET CONFIGCOUNT=0

SET POS=0
SET COMMAND=
SET SUBCOMMAND=
SET FOLDER=.
SET FOLDERSTRUCTURE=[SERVICENAME]\[OWNER]
SET SCOPE=
SET KEY=
SET SERVICENAME=
SET OWNER=
SET GROUP=
SET CLONEENABLED=Y

GOTO :PARSEOPTS


:USAGE
ECHO.%SCRIPTNAME% - Setup Dev Folder (Drive E^:)
ECHO.
ECHO.Usage: %SCRIPTNAME% [command] [subcommand] { [options] }
ECHO.
ECHO.Command:
ECHO.CONFIG   - Configure GIT with common settings
ECHO.  LIST   - List configured settings
ECHO.  APPLY  - Apply configured settings (Run as Administrator)
ECHO.
ECHO.REPO     - Work with known repos
ECHO.  LIST   - List known repos
ECHO.  CLONE  - Clone known repos
ECHO.
ECHO.CONFIG Options:
ECHO./s       - Filter scope (E.g. global, system)
ECHO./k       - Filter key (E.g. user.email)
ECHO.
ECHO.REPO Options:
ECHO./n       - Filter Service name (E.g. BitBucket, GitHub)
ECHO./o       - Filter Owner (E.g. martinsmith1968)
ECHO./g       - Filter Group (E.g. Ebooks)
ECHO.
ECHO.REPO CLONE options:
ECHO./f       - Root Folder (Default: %FOLDER%)
ECHO./t       - Folder Structure (Default: %FOLDERSTRUCTURE%)
ECHO./z       - Dry run only - NO clone is actually performed

GOTO :EOF


:PARSEOPTS
IF /I "%~1" == "/X" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-X" SET DEBUG=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/V" SET VERBOSE=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-V" SET VERBOSE=Y&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/S" SET SCOPE=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-S" SET SCOPE=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/K" SET KEY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-K" SET KEY=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/F" SET FOLDER=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-F" SET FOLDER=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/T" SET FOLDERSTRUCTURE=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-T" SET FOLDERSTRUCTURE=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/N" SET SERVICENAME=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-N" SET SERVICENAME=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/O" SET OWNER=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-O" SET OWNER=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/G" SET GROUP=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-G" SET GROUP=%~2&& SHIFT && SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "/Z" SET CLONEENABLED=N&& SHIFT && GOTO :PARSEOPTS
IF /I "%~1" == "-Z" SET CLONEENABLED=N&& SHIFT && GOTO :PARSEOPTS

IF NOT "%~1" == "" (
  SET /A POS+=1
  IF !POS! EQU 1 (
    SET COMMAND=%~1
    SET SUBCOMMAND=LIST
  ) ELSE IF !POS! EQU 2 (
    SET SUBCOMMAND=%~1
  )
  SHIFT
  GOTO :PARSEOPTS
)

:GO
IF "%DEBUG%" == "Y" (
  ECHO.COMMAND         = [%COMMAND%]
  ECHO.SUBCOMMAND      = [%SUBCOMMAND%]
  ECHO.FOLDER          = [%FOLDER%]
  ECHO.FOLDERSTRUCTURE = [%FOLDERSTRUCTURE%]
  ECHO.SCOPE           = [%SCOPE%]
  ECHO.KEY             = [%KEY%]
  ECHO.SERVICENAME     = [%SERVICENAME%]
  ECHO.OWNER           = [%OWNER%]
  ECHO.GROUP           = [%GROUP%]
  ECHO.CLONEENABLED    = [%CLONEENABLED%]
)

IF "%COMMAND%" == "" (
  CALL :USAGE
  GOTO :EOF
)

CALL :SETUPCONFIG
CALL :SETUPREPOS

IF "%DEBUG%" == "Y" @ECHO ON

GOTO :%COMMAND%_%SUBCOMMAND% >NUL 2>&1
CALL :ERROR "Command: '%COMMAND%' '%SUBCOMMAND%' is not known or supported"
GOTO :EOF


:DEFINE_CONFIG
IF "%~1" == "" GOTO :EOF
IF "%~2" == "" GOTO :EOF
IF "%~3" == "" GOTO :EOF

SET /A CONFIGCOUNT+=1
SET CONFIG[%CONFIGCOUNT%].SCOPE=%~1
SET CONFIG[%CONFIGCOUNT%].KEY=%~2
SET CONFIG[%CONFIGCOUNT%].VALUE=%~3

GOTO :EOF


:DEFINE_REPO
IF "%~1" == "" GOTO :EOF
IF "%~2" == "" GOTO :EOF
IF "%~3" == "" GOTO :EOF

SET /A REPOCOUNT+=1
SET REPO[%REPOCOUNT%].SERVICENAME=%~1
SET REPO[%REPOCOUNT%].OWNER=%~2
SET REPO[%REPOCOUNT%].URL=%~3
SET REPO[%REPOCOUNT%].FOLDER=%~4
SET REPO[%REPOCOUNT%].GROUP=%~5

GOTO :EOF


:FILTERCONFIGENTRY
SET ISFILTERED=Y

IF NOT "%SCOPE%" == "" (
  IF /I NOT "%SCOPE%" == "!CONFIG[%~1].SCOPE!" SET ISFILTERED=N
)

IF NOT "%KEY%" == "" (
  IF /I NOT "%KEY%" == "!CONFIG[%~1].KEY!" SET ISFILTERED=N
)

GOTO :EOF


:FILTERREPOENTRY
SET ISFILTERED=Y

IF NOT "%SERVICENAME%" == "" (
  IF /I NOT "%SERVICENAME%" == "!REPO[%~1].SERVICENAME!" SET ISFILTERED=N
)

IF NOT "%OWNER%" == "" (
  IF /I NOT "%OWNER%" == "!REPO[%~1].OWNER!" SET ISFILTERED=N
)

IF NOT "%GROUP%" == "" (
  IF /I NOT "%GROUP%" == "!REPO[%~1].GROUP!" SET ISFILTERED=N
)

GOTO :EOF


:SHOWCONFIGENTRY
SET INDEX=%~1
SET NO=%~2
IF "%NO%" == "" SET NO=%INDEX%
IF %NO% LSS 10 SET NO= %NO%

ECHO.%NO%: [!CONFIG[%INDEX%].SCOPE!] !CONFIG[%INDEX%].KEY! = [!CONFIG[%INDEX%].VALUE!]
GOTO :EOF


:SHOWREPOENTRY
SET INDEX=%~1
SET NO=%~2
IF "%NO%" == "" SET NO=%INDEX%
IF %NO% LSS 10 SET NO= %NO%

SET TEXT=%NO%: [!REPO[%INDEX%].SERVICENAME!]

IF NOT "!REPO[%INDEX%].GROUP!" == "" SET TEXT=%TEXT% {!REPO[%INDEX%].GROUP!}

SET TEXT=%TEXT% !REPO[%INDEX%].OWNER!: !REPO[%INDEX%].URL!

IF NOT "!REPO[%INDEX%].FOLDER!" == "" SET TEXT=%TEXT% into [!REPO[%INDEX%].FOLDER!]

ECHO.%TEXT%

GOTO :EOF


:APPLYCONFIGENTRY
IF "%~1" == "" GOTO :EOF

git config --!CONFIG[%~1].SCOPE! !CONFIG[%~1].KEY! "!CONFIG[%~1].VALUE!"

GOTO :EOF


REM *** COMMANDS ***
:CONFIG_LIST
ECHO.Found %CONFIGCOUNT% entries
SET NO=0
FOR /L %%F IN (1,1,%CONFIGCOUNT%) DO (
  CALL :FILTERCONFIGENTRY %%F
  IF "!ISFILTERED!" == "Y" (
    SET /A NO+=1
    CALL :SHOWCONFIGENTRY %%F !NO!
  )
)

GOTO :EOF


:CONFIG_APPLY
FOR /L %%F IN (1,1,%CONFIGCOUNT%) DO (
  CALL :FILTERCONFIGENTRY %%F
  IF "!ISFILTERED!" == "Y" (
    SET /A NO+=1
    CALL :SHOWCONFIGENTRY %%F !NO!
    CALL :APPLYCONFIGENTRY %%F
  )
)

GOTO :EOF


:REPO_LIST
ECHO.Found %REPOCOUNT% entries
FOR /L %%F IN (1,1,%REPOCOUNT%) DO (
  CALL :FILTERREPOENTRY %%F
  IF "!ISFILTERED!" == "Y" (
    SET /A NO+=1
    CALL :SHOWREPOENTRY %%F !NO!
  )
)

GOTO :EOF


:REPO_CLONE
ECHO.Found %REPOCOUNT% entries
FOR /L %%F IN (1,1,%REPOCOUNT%) DO (
  CALL :FILTERREPOENTRY %%F
  IF "!ISFILTERED!" == "Y" (
    SET /A NO+=1
    CALL :SHOWREPOENTRY %%F !NO!
    CALL :CLONEREPOENTRY %%F
  )
)

GOTO :EOF


:CLONEREPOENTRY
IF "%~1" == "" GOTO :EOF

SET CLONESERVICENAME=!REPO[%~1].SERVICENAME!
SET CLONEOWNER=!REPO[%~1].OWNER!
SET CLONEURL=!REPO[%~1].URL!
SET CLONEFOLDER=!REPO[%~1].FOLDER!
SET CLONEGROUP=!REPO[%~1].GROUP!

CALL :SETCLONETARGETFOLDER %~1
IF "%CLONETARGETFOLDER%" == "" (
  CALL :ERROR Unable to determine Target folder
  GOTO :EOF
)

IF "%VERBOSE%" == "Y" ECHO.Target Folder: %CLONETARGETFOLDER%
IF NOT EXIST "%CLONETARGETFOLDER%\*.*" MKDIR "%CLONETARGETFOLDER%" >NUL 2>&1

PUSHD "%CLONETARGETFOLDER%"

CALL :CLONEREPO "%CLONEURL%" "%CLONEFOLDER%"

POPD

GOTO :EOF


:SETCLONETARGETFOLDER
SET CLONETARGETFOLDER=

IF "%~1" == "" GOTO :EOF

SET CLONESERVICENAME=!REPO[%~1].SERVICENAME!
SET CLONEOWNER=!REPO[%~1].OWNER!
SET CLONEURL=!REPO[%~1].URL!
SET CLONEFOLDER=!REPO[%~1].FOLDER!
SET CLONEGROUP=!REPO[%~1].GROUP!

SET CLONETARGETFOLDER=%FOLDER%\%FOLDERSTRUCTURE%

SET CLONETARGETFOLDER=%CLONETARGETFOLDER:[SERVICENAME]=!CLONESERVICENAME!%
SET CLONETARGETFOLDER=%CLONETARGETFOLDER:[OWNER]=!CLONEOWNER!%
SET CLONETARGETFOLDER=%CLONETARGETFOLDER:[GROUP]=!CLONEGROUP!%

GOTO :EOF


:CLONEREPO
IF EXIST ".git\*.*" (
	ECHO.%CD%: Git repository already exists here
	GOTO :EOF
)

SET COMMANDPREFIX=
IF "%CLONEENABLED%" == "N" SET COMMANDPREFIX=ECHO.

ECHO.-------------------------------------------------------------------------------
IF "%~2" == "" (
    ECHO.Cloning: %~1
    %COMMANDPREFIX%GIT clone "%~1"
) ELSE (
    ECHO.Into: %~2
    %COMMANDPREFIX%GIT clone "%~1" %2
)

GOTO :EOF


:SETUPCONFIG
IF "%VERBOSE%" == "Y" ECHO.Building: Config Entries

CALL "%SCRIPTPATH%\IsAdmin.cmd" /Q

CALL :DEFINE_CONFIG global user.name          "Martin Smith"
CALL :DEFINE_CONFIG global user.email         martinsmith1968@gmail.com
CALL :DEFINE_CONFIG global credential.helper  manager-core

CALL FINDAPP.CMD Perforce p4merge.exe
IF NOT "%APP%" == "" (
  IF "%ISADMIN%" == "Y" (
    CALL :DEFINE_CONFIG system diff.tool p4merge
    CALL :DEFINE_CONFIG system difftool.p4merge "'%APP%' '$LOCAL' '$REMOTE'"
    CALL :DEFINE_CONFIG system merge.tool p4merge
    CALL :DEFINE_CONFIG system mergetool.p4merge "'%APP%' '$BASE' '$LOCAL' '$REMOTE' '$MERGED'"
  )
)

CALL FINDAPP.CMD KDiff3 kdiff3.exe
IF NOT "%APP%" == "" (
  IF "%ISADMIN%" == "Y" (
    CALL :DEFINE_CONFIG system diff.tool kdiff3
    CALL :DEFINE_CONFIG system difftool.kdiff3 "'%APP%' '$LOCAL' '$REMOTE'"
    CALL :DEFINE_CONFIG system merge.tool kdiff3
    CALL :DEFINE_CONFIG system mergetool.kdiff3 "'%APP%' '$BASE' '$LOCAL' '$REMOTE' '$MERGED'"
  )
)

CALL FINDAPP.CMD WinMerge winmergeu.exe
IF NOT "%APP%" == "" (
  IF "%ISADMIN%" == "Y" (
    CALL :DEFINE_CONFIG system diff.tool winmerge
    CALL :DEFINE_CONFIG system difftool.winmerge "'%APP%' '$LOCAL' '$REMOTE'"
  )
)

IF "%VERBOSE%" == "Y" ECHO.Done
GOTO :EOF


:ERROR
ECHO.ERROR: %*

GOTO :EOF


:SETUPREPOS
IF "%VERBOSE%" == "Y" ECHO.Building: Repositories

REM BitBucket
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/openbanking-apis.git          ""                            OpenBanking
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/dnx-solutions.co.uk.git       ""                            Website
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/spikes.git                    Spikes                        Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/angular2dive1.git             ""                            Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/vuejsdive1.git                ""                            Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/aureliadive1.git              ""                            Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/desktopmenu.git               DesktopMenu                   Apps
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/trayactionlauncher.git        TrayActionLauncher            Apps
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/golfhandicapcalculator.git    GolfHandicapCalculator        Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/leaguemanager.git             LeagueManager                 Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/windowmenu.git                WindowMenu                    Apps
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/ConsoleApplications.git       ConsoleApplications           Apps
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/spikes.git                    Spikes                        Spikes
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/traymenulauncher.git          TrayMenuLauncher              Apps
CALL :DEFINE_REPO bitbucket martinsmith1968   https://martinsmith1968@bitbucket.org/martinsmith1968/NativeConsoleApplications.git NativeConsoleApplications     Apps

CALL :DEFINE_REPO bitbucket gravity           https://martinsmith1968@bitbucket.org/martinsmith1968gravity/gravitymain.git        GravityMain                   Reference
CALL :DEFINE_REPO bitbucket gravity           https://martinsmith1968@bitbucket.org/martinsmith1968gravity/gravity.database.git   GravityDatabase               Reference
CALL :DEFINE_REPO bitbucket gravity           https://martinsmith1968@bitbucket.org/martinsmith1968gravity/gravity.utils.git      GravityUtils                  Reference
CALL :DEFINE_REPO bitbucket gravity           https://martinsmith1968@bitbucket.org/martinsmith1968gravity/ci-site-deploy.git     Gravity-SiteDeploy            Reference

CALL :DEFINE_REPO bitbucket collect-r         https://martinsmith1968@bitbucket.org/collect-r/database-mysql.git                  ""                            Projects

CALL :DEFINE_REPO bitbucket deputamadre1996   https://bitbucket.org/deputamadre1996/free-security-ebooks.git                      ""                            EBooks

CALL :DEFINE_REPO bitbucket eldiablo100000    https://bitbucket.org/eldiablo100000/cybersecurity-ebooks.git                       ""                            EBooks

CALL :DEFINE_REPO bitbucket priyabrata_dash   https://bitbucket.org/priyabrata_dash/web-development-ebooks.git                    ""                            EBooks


REM GitHub
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/DNX.GlobalHotKeys.git                              ""                            NETLibrary
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/DNX.Helpers.git                                    ""                            NETLibrary
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/startbootstrap-sb-admin-2.git                      ""                            Tutorial
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/You-Dont-Know-JS.git                               ""                            EBooks
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/AngularJSAuthentication.git
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/Griffin.AdoNetFakes.git                            ""                            NETLibrary
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/ookii.commandline.git                              ""                            NETLibrary
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/OpenAPI.CodeGenerator.git
CALL :DEFINE_REPO github  martinsmith1968   https://github.com/martinsmith1968/Caffeinated.git                                    ""                            Apps

CALL :DEFINE_REPO github  aaquresh          https://github.com/aaquresh/CITraining                                                ""                            EBooks
CALL :DEFINE_REPO github  appccelerate      https://github.com/appccelerate/commandlineparser.git                                 ""                            NETLibrary
CALL :DEFINE_REPO github  Azure-Samples     https://github.com/Azure-Samples/service-fabric-dotnet-quickstart                     ""                            Tutorial

CALL :DEFINE_REPO github  CemraJC           https://github.com/CemraJC/clickfix
CALL :DEFINE_REPO github  ClearBank         https://github.com/clearbank/fi-api-signtool
CALL :DEFINE_REPO github  ClearBank         https://github.com/clearbank/fi-api-signtool-python
CALL :DEFINE_REPO github  ClearBank         https://github.com/clearbank/openapi-generator
cALL :DEFINE_REPO github  ClearBank         https://github.com/clearbank/openssl-docker.git
CALL :DEFINE_REPO github  ClearBank         https://github.com/clearbank/signtool-api
CALL :DEFINE_REPO github  commandlineparser https://github.com/commandlineparser/commandline                                      ""                            NETLibrary

CALL :DEFINE_REPO github  daniellittledev   https://github.com/daniellittledev/Enexure.MicroBus.git                               ""                            NETLibrary
CALL :DEFINE_REPO github  dmnd              https://github.com/dmnd/Caffeinated.git                                               ""                            Apps
CALL :DEFINE_REPO github  dnGrep            https://github.com/dnGrep/dnGrep.git                                                  ""                            Apps

CALL :DEFINE_REPO github  EBookFoundation   https://github.com/EbookFoundation/free-programming-books                             ""                            EBooks

CALL :DEFINE_REPO github  fclp              https://github.com/fclp/fluent-command-line-parser.git                                ""                            NETLibrary
CALL :DEFINE_REPO github  fuhsjr00          https://github.com/fuhsjr00/bug.n.git                                                 ""                            AHKLibrary

CALL :DEFINE_REPO github  getify            https://github.com/getify/You-Dont-Know-JS.git                                        ""                            EBooks

CALL :DEFINE_REPO github  heaths            https://github.com/heaths/Caffeine.git                                                ""                            Apps
CALL :DEFINE_REPO github  hluk              https://github.com/hluk/CopyQ                                                         ""                            Apps
CALL :DEFINE_REPO github  HotKeyIT          https://github.com/HotKeyIt/TT.git
CALL :DEFINE_REPO github  HotKeyIT          https://github.com/HotKeyIt/_Struct.git
CALL :DEFINE_REPO github  Humanizr          https://github.com/Humanizr/Humanizer                                                 ""                            NETLibrary
CALL :DEFINE_REPO github  hypnguyen1209     https://github.com/hypnguyen1209/JS-ebook                                             ""                            EBooks

CALL :DEFINE_REPO github  IdentityServer    https://github.com/IdentityServer/IdentityServer4                                     ""                            Apps
CALL :DEFINE_REPO github  imerzan           https://github.com/imerzan/Caffeine.git                                               ""                            Apps

CALL :DEFINE_REPO github  janikvonrotz      https://github.com/janikvonrotz/awesome-powershell                                    ""                            Powershell
CALL :DEFINE_REPO github  jgauffin          https://github.com/jgauffin/Griffin.AdoNetFakes.git                                   ""                            NETLibrary
CALL :DEFINE_REPO github  jhulick           https://github.com/jhulick/bookstuff                                                  ""                            EBooks

CALL :DEFINE_REPO github  maestrith         https://github.com/maestrith/AHK-Studio.git
CALL :DEFINE_REPO github  maestrith         https://github.com/maestrith/AHK-Studio-Plugins.git
CALL :DEFINE_REPO github  maestrith         https://github.com/maestrith/GUI_Creator.git
CALL :DEFINE_REPO github  madelson          https://github.com/madelson/DistributedLock.git
CALL :DEFINE_REPO github  Microsoft         https://github.com/microsoft/AzureKeyVaultExplorer.git
CALL :DEFINE_REPO github  Microsoft         https://github.com/Microsoft/OpenAPI.NET.git
CALL :DEFINE_REPO github  Microsoft         https://github.com/Microsoft/PowerToys.git
CALL :DEFINE_REPO github  MrJul             https://github.com/MrJul/ForTea.git

CALL :DEFINE_REPO github  nohwnd            https://github.com/nohwnd/Assert                                                      ""                            Powershell

CALL :DEFINE_REPO github  OpenAPITools      https://github.com/OpenAPITools/openapi-generator.git
CALL :DEFINE_REPO github  OpenAPITools      https://github.com/OpenAPITools/swagger-parser.git

CALL :DEFINE_REPO github  paolosalvatori    https://github.com/paolosalvatori/ServiceBusExplorer.git                              ""                            Apps
CALL :DEFINE_REPO github  pavel-a           https://github.com/pavel-a/ddverpatch                                                 ""                            Tools
CALL :DEFINE_REPO github  phpmad            https://github.com/phpmad/free-ebooks                                                 ""                            EBooks
CALL :DEFINE_REPO github  ploeh             https://github.com/ploeh/ZeroToNine.git                                               ""                            Tools
CALL :DEFINE_REPO github  pngan             https://github.com/pngan/winlayout                                                    ""                            Apps

CALL :DEFINE_REPO github  RickStrahl        https://github.com/RickStrahl/MarkdownMonster                                         ""                            Apps
CALL :DEFINE_REPO github  RolandPheasant    https://github.com/RolandPheasant/TailBlazer.git                                      ""                            Tools
CALL :DEFINE_REPO github  rwese             https://github.com/rwese/DockWin                                                      ""                            Reference

CALL :DEFINE_REPO github  shajul            https://github.com/shajul/Autohotkey.git                                              ""                            AHKLibrary
CALL :DEFINE_REPO github  snakefoot         https://github.com/snakefoot/snaketail-net.git                                        ""                            Tools
CALL :DEFINE_REPO github  Sparin            https://github.com/Sparin/IconsRestorerConsole                                        ""                            Apps
CALL :DEFINE_REPO github  sr3d              https://github.com/sr3d/javascript-ebooks                                             ""                            EBooks
CALL :DEFINE_REPO github  StackExchange     https://github.com/StackExchange/Dapper.git                                           ""                            NETLibrary
CALL :DEFINE_REPO github  SvenGroot         https://github.com/SvenGroot/ookii.commandline.git                                    ""                            NETLibrary

CALL :DEFINE_REPO github  tonsky            https://github.com/tonsky/FiraCode                                                    ""                            Fonts
CALL :DEFINE_REPO github  tkellogg          https://github.com/tkellogg/Jump-Location                                             ""                            Powershell

REM DMCA Takedown
REM CALL :DEFINE_REPO github transidai1705 https://github.com/transidai1705/javascript-ebooks

CALL :DEFINE_REPO github  vaquarkhan        https://github.com/vaquarkhan/vaquarkhan                                              ""                            EBooks
CALL :DEFINE_REPO github  vaquarkhan        https://github.com/vaquarkhan/microservices-recipes-a-free-gitbook                    ""                            EBooks

CALL :DEFINE_REPO github  vors              https://github.com/vors/ZLocation                                                     ""                            Powershell

CALL :DEFINE_REPO github  zarunbal          https://github.com/zarunbal/LogExpert.git                                             ""                            Tools


REM GitLab
CALL :DEFINE_REPO gitlab  martinsmith1968   https://gitlab.com/martinsmith1968/consoleapplications.git                            ConsoleApplications           Tools
CALL :DEFINE_REPO gitlab  martinsmith1968   https://gitlab.com/martinsmith1968/windowextensions.net.git                           WindowExtensions              Tools

IF "%VERBOSE%" == "Y" ECHO.Done
GOTO :EOF
