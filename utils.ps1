<#
.SYNOPSIS
    Setup UTILS
.DESCRIPTION
.PARAMETER command
    The command to execute ( (l)ist / (i)nstall )
.PARAMETER 
.EXAMPLE
    C:\PS>
    utils list              -- Show the defined services
    utils install           -- Install services
.NOTES
    Author: Martin Smith
    Date:   2024-01-04
#>
param (
    [string]$command = "install"
   ,[string]$targetFolder = ""
   ,[string]$osType = "Any"
   ,[bool]$modifyPath = $true
   ,[bool]$verbose = $true
   ,[bool]$debug = $true
)

################################################################################
# TODO:
# - Separate definitions for x64 and x32 (OptimumX, etc)
################################################################################


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
enum InstallType {
    None
    CopyFiles
    ExtractZip
    InstallCmd
}

enum OSType {
    Any
    x64
    x32
}

enum InstallOptions {
    RenameReadmes
    RenameLicence
    ExtractWildcard
    ExtractCommand
    ExtractCustomArguments
    RenameTarget
    ShortcutFilenames
    ShortcutTarget
}


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# Init
$startDateTime = Get-Date
$startDateTimeFormatted = Get-Date -Format "yyyyMMdd-HHmmss"
$scriptName = [System.IO.Path]::GetFilenameWithoutExtension($PSCommandPath)
$logFileName = Join-Path $PSScriptRoot ($scriptName + "-" + $startDateTimeFormatted + ".log")


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
Function Get-OSType() {
    Switch ([IntPtr]::Size) {
        4 { return [OSType]::x32 }
        8 { return [OSType]::x64 }
        default { return [OSType]::x64 }
    }
}

function Get-TempFileName() {
    $uniqueId = Get-Date -Format "yyyyMMddHHmmss"
    return Join-Path $PSScriptRoot "temp" ("Data" + $uniqueId + ".tmp")
}

function Execute-Process(
    [string]$fileName
   ,[string]$arguments
   ,[bool]$verbose
) {
    $tempFileName = Get-TempFileName
    Start-Process -FilePath $fileName -ArgumentList $arguments -Wait -Verbose:$verbose -WindowStyle Hidden -RedirectStandardOutput $tempFileName
    if ($verbose) {
        Write-Log-AllFromFile $tempFileName
    }
    Remove-Item -Path $tempFileName -Force -ErrorAction SilentlyContinue
}

function Write-Log([string]$text) {
    Write-Host $text
    Add-Content -Path $logFileName -Value $text
}

function Write-Log-All([string[]] $texts) {
    foreach($text in $texts) {
        Write-Log $text
    }
}
function Write-Log-AllFromFile([string] $fileName) {
    foreach($line in Get-Content $fileName) {
        Write-Log $line
    }
}

class AppDefinition{
    [string]$Id
    [string]$GroupName
    [OSType]$OSType
    [string]$SourceFolder
    [string]$SourceWildcard
    [string]$TargetFolder
    [InstallType]$InstallType
    [InstallOptions[]]$Options
    [hashtable]$Parameters

    AppDefinition(
        [string]$id,
        [string]$groupName,
        [OSType]$osType,
        [string]$sourceFolder,
        [string]$sourceWildcard,
        [string]$targetFolder,
        [InstallType]$installType,
        [InstallOptions[]]$options,
        [hashtable]$parameters
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Options        = $options
        $this.Parameters     = $parameters
    }

    AppDefinition(
        [string]$id,
        [string]$groupName,
        [OSType]$osType,
        [string]$sourceFolder,
        [string]$sourceWildcard,
        [string]$targetFolder,
        [InstallType]$installType,
        [InstallOptions[]]$options
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Options        = $options
        $this.Parameters     = @{}
    }

    AppDefinition(
        [string]$id,
        [string]$groupName,
        [OSType]$osType,
        [string]$sourceFolder,
        [string]$sourceWildcard,
        [string]$targetFolder,
        [InstallType]$installType,
        [hashtable]$parameters
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Options        = @()
        $this.Parameters     = $parameters
    }

    AppDefinition(
        [string]$id,
        [string]$groupName,
        [OSType]$osType,
        [string]$sourceFolder,
        [string]$sourceWildcard,
        [string]$targetFolder,
        [InstallType]$installType
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Options        = @()
        $this.Parameters     = @{}
    }

    [void] Install(
        [string]$baseTargetFolder
       ,[bool]$verbose
       ,[bool]$debug
    ) {
        $sourcePath = Join-Path -Path $PSScriptRoot -ChildPath $this.SourceFolder
        $targetPath = Join-Path -Path $baseTargetFolder -ChildPath $this.TargetFolder
        Write-Log "-- Source : ${sourcePath}"
        Write-Log "-- Target : ${targetPath}"
        Write-Log "-- InstallType : $($this.InstallType)"

        $sourceFiles = Get-ChildItem -Path $sourcePath -Filter $this.SourceWildcard

        foreach($sourceFile in $sourceFiles) {

            if ($this.InstallType -eq [InstallType]::CopyFiles) {
                Write-Log "-- Copying: ${sourceFile}"
                Copy-Item -Path $sourceFile -Destination $targetPath -Force -Verbose:$verbose
            }
            elseif ($this.InstallType -eq [InstallType]::ExtractZip) {
                Write-Log "-- Extracting: ${sourceFile}"

                $commandFullName = Join-Path $baseTargetFolder "bin" "7za.exe"
                $arguments = " ""$($sourceFile.FullName)"" -o""${targetPath}"" -y -bd -bb2"

                $command = "x"
                if ($this.Parameters.ContainsKey([InstallOptions]::ExtractCommand)) {
                    $command = $this.Parameters[[InstallOptions]::ExtractCommand]
                }
                $arguments = $command + $arguments

                if ($this.Parameters.ContainsKey([InstallOptions]::ExtractWildcard)) {
                    $wildcard = $this.Parameters[[InstallOptions]::ExtractWildcard]
                    $arguments += " ${wildcard}"
                }

                if ($this.Parameters.ContainsKey([InstallOptions]::ExtractCustomArguments)) {
                    $customArguments = $this.Parameters[[InstallOptions]::ExtractCustomArguments]
                    $arguments += " ${customArguments}"
                }

                Execute-Process $commandFullName $arguments $verbose
            }

            foreach($option in $this.Options) {
                if ($option -eq [InstallOptions]::RenameReadmes) {
                    $installBaseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

                    $licenceFiles = Get-ChildItem -Path $targetPath -Filter readme*.*
                    foreach($readmeFile in $licenceFiles) {
                        $oldExtension = [System.IO.Path]::GetExtension($readmeFile)
                        $newFileName = Join-Path $targetPath ($installBaseName + $oldExtension)
                        Write-Log "-- Renaming: ${readmeFile} - ${newFileName}"
                        Move-Item -Path $readmeFile -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
                elseif ($option -eq [InstallOptions]::RenameLicence) {
                    $installBaseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

                    $licenceFiles = Get-ChildItem -Path $targetPath -Filter licen*.*
                    foreach($licenceFile in $licenceFiles) {
                        $oldName = [System.IO.Path]::GetFileNameWithoutExtension($licenceFile)
                        $newFileName = Join-Path $targetPath ($installBaseName + "." + $oldName)
                        Write-Log "-- Renaming: ${licenceFile} - ${newFileName}"
                        Move-Item -Path $licenceFile -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
            }

            if ($this.Parameters.ContainsKey([InstallOptions]::RenameTarget)) {
                $renameTargets = ($this.Parameters[[InstallOptions]::RenameTarget]).Split("|")
                foreach($renameTarget in $renameTargets) {
                    $renameSourceAndTarget = $renameTarget.Split("=")
                    $wildcard = $renameSourceAndTarget[0]
                    $newName = $renameSourceAndTarget[1]

                    $targetFileNames = Get-ChildItem -Path $targetPath -Filter $wildcard
                    foreach($targetFileName in $targetFileNames) {
                        $newFileName = Join-Path $targetPath $newName
                        Write-Log "-- Renaming: ${targetFileName} - ${newFileName}"
                        Move-Item -Path $targetFileName -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
            }
            elseif ($this.Parameters.ContainsKey([InstallOptions]::ShortcutFilenames)) {
                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $startupPath = [Environment]::GetFolderPath("Startup")

                $shortcutPath = $desktopPath
                if ($this.Parameters.ContainsKey([InstallOptions]::ShortcutTarget)) {
                    $installTarget = $this.Parameters([InstallOptions]::ShortcutTarget)
                    if ($installTarget -eq "shell:startup") {
                        $shortcutPath = $startupPath
                    }
                }

                $shortcutTargets = ($this.Parameters[[InstallOptions]::ShortcutFilenames]).Split("|")
                foreach($shortcutTarget in $shortcutTargets) {
                    $shortcutFileNameAndName = $shortcutTarget.Split("=")
                    $fileName = $shortcutFileNameAndName[0]
                    $name = $shortcutFileNameAndName[1]

                    $targetFileNames = Get-ChildItem -Path $targetPath -Filter $fileName
                    foreach($targetFileName in $targetFileNames) {
                        $shortcutCommand = Join-Path $baseTargetFolder "bin" "shortcut32.exe"
                        $shortcutFileName = Join-Path $shortcutPath ($name + ".lnk")
                        $shortcutTargetFileName = Join-Path $targetPath $fileName
                        $arguments = "/F:""${shortcutFileName}"" /A:Create /T:""${shortcutTargetFileName}"""
                        Write-Log "-- Creating Shortcut: ${shortcutFileName} - ${shortcutTargetFileName}"
                        Execute-Process $shortcutCommand $arguments $verbose
                    }
                }
            }
        }
    }
}

#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
$separatorLine = [string]::new('-', 100)

$defined_apps = @(
     [AppDefinition]::new("7za command",                    "Mandatory",  [OSType]::Any, "apps\7zip\x64",                                            "*.exe",               "bin",                      [InstallType]::CopyFiles)
    ,[AppDefinition]::new("My Native Console Apps",         "Essentials", [OSType]::x64, "apps\martinsmith1968\NativeWindowsConsoleApplicationsCPP", "*.zip",               "msbin",                    [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes ))
    ,[AppDefinition]::new("My Legacy Console Apps",         "Essentials", [OSType]::Any, "apps\martinsmith1968\legacy",                              "*.*",                 "msbin",                    [InstallType]::CopyFiles)
    ,[AppDefinition]::new("GnuWin32",                       "Standard",   [OSType]::Any, "apps\GnuWin32",                                            "*.zip",               "",                         [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "gnuwin32\*.*" ; [InstallOptions]::ExtractCustomArguments = "-r" })
    ,[AppDefinition]::new("OptimumX Console Apps",          "Standard",   [OSType]::x64, "apps\OptimumX",                                            "*.zip",               "bin",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes ))
    ,[AppDefinition]::new("NirSoft Console Essentials",     "Standard",   [OSType]::Any, "apps\nirsoft\console",                                     "*.zip",               "bin",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes ))
    ,[AppDefinition]::new("Fourmilab Crypto tools",         "Standard",   [OSType]::Any, "apps\fourmilab",                                           "*.zip",               "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Stahlworks SFK",                 "Standard",   [OSType]::Any, "apps\stahlworks",                                          "sfk.zip",             "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Micro Text Editor",              "Standard",   [OSType]::x32, "apps\micro",                                               "*win32*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Micro Text Editor",              "Standard",   [OSType]::x64, "apps\micro",                                               "*win64*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Nano Text Editor",               "Standard",   [OSType]::x32, "apps\nano",                                                "*win32*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Nano Text Editor Syntax",        "Standard",   [OSType]::x32, "apps\nano",                                                "*win32*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "syntax\*" })
    ,[AppDefinition]::new("Nano Text Editor",               "Standard",   [OSType]::x64, "apps\nano",                                                "*win64*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Nano Text Editor Syntax",        "Standard",   [OSType]::x64, "apps\nano",                                                "*win64*.zip",         "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "syntax\*" })
    ,[AppDefinition]::new("VerPatch",                       "Standard",   [OSType]::Any, "apps\ddbug",                                               "*.zip",               "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Find and Replace Tool",          "Standard",   [OSType]::Any, "apps\fart",                                                "*.zip",               "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Info-ZIP",                       "Standard",   [OSType]::x32, "apps\info-zip",                                            "*win32*.zip",         "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Info-ZIP",                       "Standard",   [OSType]::x64, "apps\info-zip",                                            "*win64*.zip",         "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("XD 2 Markdown",                  "Developer",  [OSType]::Any, "apps\formix",                                              "*.zip",               "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("AutoHotKey",                     "Developer",  [OSType]::Any, "apps\AutoHotKey",                                          "*.zip",               "AutoHotKey",               [InstallType]::ExtractZip)
    ,[AppDefinition]::new("JSON Query tool",                "Standard",   [OSType]::x32, "apps\jq\x32",                                              "*.exe",               "bin",                      [InstallType]::CopyFiles,  @{ [InstallOptions]::RenameTarget = "jq-*.exe=jq.exe" })
    ,[AppDefinition]::new("JSON Query tool",                "Standard",   [OSType]::x64, "apps\jq\x64",                                              "*.exe",               "bin",                      [InstallType]::CopyFiles,  @{ [InstallOptions]::RenameTarget = "jq-*.exe=jq.exe" })
    ,[AppDefinition]::new("XML Query tool",                 "Standard",   [OSType]::Any, "apps\xq",                                                  "*.zip",               "bin",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes, [InstallOptions]::RenameLicence ))
    ,[AppDefinition]::new("YAML Query tool",                "Standard",   [OSType]::x32, "apps\yq\x32",                                              "*.zip",               "bin",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes, [InstallOptions]::RenameLicence ))
    ,[AppDefinition]::new("YAML Query tool",                "Standard",   [OSType]::x64, "apps\yq\x64",                                              "*.zip",               "bin",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameReadmes, [InstallOptions]::RenameLicence ))
    ,[AppDefinition]::new("Naughter ShelExec",              "Standard",   [OSType]::x64, "apps\naughter",                                            "shelexec.zip",        "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "ReleaseU64C\*.exe" })
    ,[AppDefinition]::new("Naughter ShelExec",              "Standard",   [OSType]::x32, "apps\naughter",                                            "shelexec.zip",        "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "ReleaseUC\*.exe" })
    ,[AppDefinition]::new("Naughter StartX",                "Standard",   [OSType]::x64, "apps\naughter",                                            "startx.zip",          "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "ReleaseU64\*.exe" })
    ,[AppDefinition]::new("Naughter StartX",                "Standard",   [OSType]::x32, "apps\naughter",                                            "startx.zip",          "bin",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractCommand = "e" ; [InstallOptions]::ExtractWildcard = "ReleaseU\*.exe" })
    ,[AppDefinition]::new("Microsoft File Checksum Tool",   "Standard",   [OSType]::Any, "apps\Microsoft\FileChecksumIntegrityVerifier",             "*.zip",               "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Microsoft XSL Tool",             "Standard",   [OSType]::Any, "apps\Microsoft\msxsl",                                     "msxsl.exe",           "bin",                      [InstallType]::CopyFiles)
    ,[AppDefinition]::new("Microsoft SysInternals",         "Standard",   [OSType]::Any, "apps\Microsoft\SysInternals",                              "*.zip",               "sysinternals",             [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Microsoft Win2000 Resource Kit", "Standard",   [OSType]::Any, "apps\Microsoft\Win2000ResourceKit",                        "*.zip",               "bin",                      [InstallType]::ExtractZip)

    ,[AppDefinition]::new("Topdesk",                        "Standard",   [OSType]::Any, "apps-win\SnadBoy",                                         "*.zip",               "win",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" ; [InstallOptions]::ShortcutFilenames = "*.exe=Topdesk" ; [InstallOptions]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("Window Extensions",              "Standard",   [OSType]::Any, "apps-win\martinsmith1968\WindowExtensions",                "*.zip",               "mswin\WindowExtensions",   [InstallType]::ExtractZip, @{ [InstallOptions]::ShortcutFilenames = "WindowExtensions.exe=Window Extensions" ; [InstallOptions]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("QuickCalendar",                  "Standard",   [OSType]::Any, "apps-win\martinsmith1968\QuickCalendar",                   "*.zip",               "mswin\QuickCalendar",      [InstallType]::ExtractZip, @{ [InstallOptions]::ShortcutFilenames = "WindowExtensions.exe=Window Extensions" ; [InstallOptions]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("Metapad",                        "Standard",   [OSType]::Any, "apps-win\metapad",                                         "*.zip",               "win",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ShortcutFilenames = "metapad.exe=Metapad" })
    ,[AppDefinition]::new("Notepad2",                       "Standard",   [OSType]::Any, "apps-win\notepad2",                                        "*.zip",               "win",                      [InstallType]::ExtractZip, @( [InstallOptions]::RenameLicence ), @{ [InstallOptions]::ShortcutFilenames = "notepad2.exe=Notepad 2" })
    ,[AppDefinition]::new("Notepad3",                       "Standard",   [OSType]::Any, "apps-win\notepad3",                                        "*.zip",               "win\Notepad3",             [InstallType]::ExtractZip, @{ [InstallOptions]::ShortcutFilenames = "Notepad3.exe=Notepad 3" })
    ,[AppDefinition]::new(".NET Version Detector",          "Standard",   [OSType]::Any, "apps-win\DotNETVersionDetector",                           "*.zip",               "win",                      [InstallType]::ExtractZip, @{ [InstallOptions]::ShortcutFilenames = "dotnetver.exe=NET Version Detector" })
    ,[AppDefinition]::new("Desktop OK",                     "Standard",   [OSType]::x64, "apps-win\SoftwareOK\x64",                                  "DesktopOK*.zip",      "win\SoftwareOK",           [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" ; [InstallOptions]::ShortcutFilenames = "DesktopOK*.exe=Desktop OK" })
    ,[AppDefinition]::new("FontView OK",                    "Standard",   [OSType]::x64, "apps-win\SoftwareOK\x64",                                  "FontView*.zip",       "win\SoftwareOK",           [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" ; [InstallOptions]::ShortcutFilenames = "FontViewOK*.exe=FontView OK" })
    ,[AppDefinition]::new("Desktop OK",                     "Standard",   [OSType]::x32, "apps-win\SoftwareOK\x32",                                  "DesktopOK*.zip",      "win\SoftwareOK",           [InstallType]::ExtractZip, @{ [InstallOptions]::ExtractWildcard = "*.exe" ; [InstallOptions]::ShortcutFilenames = "DesktopOK*.exe=Desktop OK" })

    ,[AppDefinition]::new("Login Script",                   "Essential",  [OSType]::Any, "",                                                         "Login.cmd",           "",                         [InstallType]::None, @{ [InstallOptions]::ShortcutFilenames = "Login.cmd=Login Script" ; [InstallOptions]::ShortcutTarget = "shell:startup" })
)


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# Start
Write-Log $separatorLine
Write-Log "-- Started at ${startDateTime}"
Write-Log $separatorLine

# Validate
if ([string]::IsNullOrEmpty($targetFolder)) {
    $targetFolder = $PSScriptRoot
}

if ($osType -eq [OSType]::Any) {
    $osType = Get-OSType
}
if ($verbose) {
    Write-Log "** Processing OS Type: ${osType}"
}

# Filter based on parameters
$install_apps = @()
$index = 0
foreach($defined_app in $defined_apps) {
    $index++
    $include = $False
    if ($defined_app.OSType -eq $osType -or $defined_app.OSType -eq [OSType]::Any) {
        $include = $True
    }

    if ($include) {
        if ($verbose) {
            Write-Log "** Including: $($defined_app.Id) [$($defined_app.OSType)]"
        }
        $install_apps += $defined_app
    }
}

# Install Apps
Push-Location $PSScriptRoot

Write-Log "** Installing: $($defined_apps.Count) apps"
$index = 0
foreach($app in $install_apps) {
    $index++
    Write-Log $separatorLine
    Write-Log "-- ${index}: $($app.Id)"

    $app.Install($targetFolder, $verbose, $debug)
}

if ($modifyPath) {
    # Add target directories to PATH
    Write-Log $separatorLine
    Write-Log "-- Building new PATHs"

    $utilsPaths = @()
    $utilsPaths += (Join-Path $targetFolder "cmd")
    $utilsPaths += (Join-Path $targetFolder "bin")
    $utilsPaths += (Join-Path $targetFolder "msbin")
    $utilsPaths += (Join-Path $targetFolder "gnuwin32" "bin")
    $utilsPaths += (Join-Path $targetFolder "gnuwin32" "sbin")
    $utilsPaths += (Join-Path $targetFolder "sysinternals")

    Write-Log "-- Retrieving existing PATH"
    $existingPath = ([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User))
    $existingPaths = $existingPath.Split(";") | where-object { $_ -notlike ($targetFolder + "*") } | foreach-object { $_.Trim("\") }
    Write-Log "-- Building new PATH value"
    $newPaths = $utilsPaths + $existingPaths
    $newPathValue = $newPaths -join ";"
    Write-Log "-- Setting PATH value"
    Write-Log ""
    Write-Log "Old PATH : ${existingPath}"
    Write-Log-All ($existingPath.split(";"))
    Write-Log ""
    Write-Log "New PATH : ${newPathValue}"
    Write-Log-All ($newPathValue.split(";"))
    [System.Environment]::SetEnvironmentVariable('PATH', $newPathValue, [System.EnvironmentVariableTarget]::User)
}

# Complete
Write-Log
Write-Log $separatorLine
Write-Log "-- Success !!"
Write-Log $separatorLine

Pop-Location
