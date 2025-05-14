<#
.SYNOPSIS
    Setup UTILS
.DESCRIPTION
.PARAMETER command
    The command to execute ( (l)ist / (i)nstall )
.PARAMETER 
.EXAMPLE
    C:\PS>
    Install-Utils list              -- Show the defined services
    Install-Utils install           -- Install services
.NOTES
    Author: Martin Smith
    Date:   2024-01-04
#>
param (
    [string]$command = "install"
   ,[string]$targetFolder = "c:\utils"
   ,[string]$osType = "Any"
   ,[string[]]$groups = @( "Mandatory", "Standard", "Essentials", "Developer" )
   ,[switch][bool]$noModifyPath = $false
   ,[switch][bool]$dryRun = $false
   ,[switch][bool]$quiet = $false
   ,[switch][bool]$debug = $false
)

$modifyPath = !$noModifyPath
$verbose = !$quiet

if ($debug) {
    Write-Host "----------------------------------------"
    Write-Host "command:      $command"
    Write-Host "targetFolder: $targetFolder"
    Write-Host "osType:       $osType"
    Write-Host "groups:       $groups"
    Write-Host "modifyPath:   $modifyPath"
    Write-Host "dryRun:       $dryRun"
    Write-Host "verbose:      $verbose"
    Write-Host "debug:        $debug"

    if ($groups.Count -gt 0) {
        Write-Host "----------------------------------------"
        $groupCount = 0
        foreach($group in $groups) {
            ++$groupCount
            Write-Host "Group ${groupCount}: $group"
        }
    }
    Write-Host "----------------------------------------"
}


################################################################################
# TODO:
# General
# - Allow filtering at invocation (Group, AppName, etc)
# - Support DrynRun - install with all options that has creates/updates no files
#
# Apps
# - AzCopy
# - blat
# - BulkRenameUtility
# - ffmpeg
# - gnome
# - html-tidy
# - hwinfo
# - kubetools
# - minitrue
# - mobzsystems
# - nirsoft
# - NuGet
#
# Win Apps
# - DesktopTrayLauncher
# - mobzsystems
# - RapidEE
# - Rufus
# - SJFranke
# - SoftwareOK
# - SystemInformer
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

enum InstallAction
{
    RenameReadmes
    RenameLicence
    RenameFAQ
    RenameNews
    ClearTargetFolder
}

enum InstallParameter {
    ExtractWildcard
    ExtractCommand
    ExtractCustomArguments
    RenameTarget
    ShortcutFilenames
    ShortcutTarget
    ShortcutFolder
}


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# Init
$startDateTime          = Get-Date
$startDateTimeFormatted = Get-Date -Format "yyyyMMdd-HHmmss"
$scriptName             = [System.IO.Path]::GetFilenameWithoutExtension($PSCommandPath)
$logFileName            = Join-Path $PSScriptRoot ($scriptName + "-" + $startDateTimeFormatted + ".log")


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# Functions
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

function New-FolderIfNotExists([string]$targetFolder) {
    if (-Not (Test-Path -Path $targetFolder)) {
        New-Item $targetFolder -ItemType Directory | Out-Null
    }
}

function New-Process(
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

function ApplyStandardShortcutMenu([hashtable]$parameters) {
    $parameters += @{ [InstallParameter]::ShortcutTarget = "shell:programsmenu" ; [InstallParameter]::ShortcutFolder = "utils" }
    return $parameters
}


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# AppDefinition class
class AppDefinition{
    [string]$Id
    [string]$GroupName
    [OSType]$OSType
    [string]$SourceFolder
    [string]$SourceWildcard
    [string]$TargetFolder
    [InstallType]$InstallType
    [InstallAction[]]$Actions
    [hashtable]$Parameters

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
        $this.Actions        = @()
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
        [InstallAction[]]$actions
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Actions        = $actions
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
        $this.Actions        = @()
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
        [InstallAction[]]$actions,
        [hashtable]$parameters
    ) {
        $this.Id             = $id
        $this.GroupName      = $groupName
        $this.OSType         = $osType
        $this.SourceFolder   = $sourceFolder
        $this.SourceWildcard = $sourceWildcard
        $this.TargetFolder   = $targetFolder
        $this.InstallType    = $installType
        $this.Actions        = $actions
        $this.Parameters     = $parameters
    }


    #------------------------------------------------------------------------------------------------------------------------
    #------------------------------------------------------------------------------------------------------------------------
    # Install an App
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

        New-FolderIfNotExists $targetPath

        $sourceFiles = Get-ChildItem -Path $sourcePath -Filter $this.SourceWildcard

        #------------------------------------------------------------------------------------------------------------------------
        # Pre-Process Actions
        #------------------------------------------------------------------------------------------------------------------------
        if ($this.Actions.Contains([InstallAction]::ClearTargetFolder)) {
            Write-Log "-- Clear Target Folder: ${targetPath}"
            Remove-Item -Path $targetPath\* -Recurse -Force -Verbose:$verbose -ErrorAction SilentlyContinue
        }

        #------------------------------------------------------------------------------------------------------------------------
        # Process each source file (Normally only 1 anyway)
        #------------------------------------------------------------------------------------------------------------------------
        $fileCount = $sourceFiles.Count
        $fileIndex = 0
        foreach($sourceFile in $sourceFiles) {
            ++$fileIndex

            Write-Log $Global:bannerPartLine
            Write-Log "-- File ${fileIndex} / ${fileCount} : ${sourceFile}"

            # InstallType - CopyFile
            if ($this.InstallType -eq [InstallType]::CopyFiles) {
                Write-Log "-- Copying: ${sourceFile}"
                Copy-Item -Path $sourceFile -Destination $targetPath -Force -Verbose:$verbose
            }
            # InstallType - ExtractZip
            elseif ($this.InstallType -eq [InstallType]::ExtractZip) {
                Write-Log "-- Extracting: ${sourceFile}"

                $commandFullName = Join-Path $baseTargetFolder "bin" "7za.exe"
                $arguments = " ""$($sourceFile.FullName)"" -o""${targetPath}"" -y -bd -bb2"

                $command = "x"
                if ($this.Parameters.ContainsKey([InstallParameter]::ExtractCommand)) {
                    $command = $this.Parameters[[InstallParameter]::ExtractCommand]
                }
                $arguments = $command + $arguments

                if ($this.Parameters.ContainsKey([InstallParameter]::ExtractWildcard)) {
                    $wildcard = $this.Parameters[[InstallParameter]::ExtractWildcard]
                    $arguments += " ${wildcard}"
                }

                if ($this.Parameters.ContainsKey([InstallParameter]::ExtractCustomArguments)) {
                    $customArguments = $this.Parameters[[InstallParameter]::ExtractCustomArguments]
                    $arguments += " ${customArguments}"
                }

                Invoke-ExecuteProcess $commandFullName $arguments $verbose
            }

            #------------------------------------------------------------------------------------------------------------------------
            # Process each defined Action
            #------------------------------------------------------------------------------------------------------------------------
            foreach($action in $this.Actions) {
                # Action - RenameReadmes
                if ($action -eq [InstallAction]::RenameReadmes) {
                    $installBaseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

                    $licenceFiles = Get-ChildItem -Path $targetPath -Filter readme*.*
                    foreach($readmeFile in $licenceFiles) {
                        $oldExtension = [System.IO.Path]::GetExtension($readmeFile)
                        $newFileName = Join-Path $targetPath ($installBaseName + $oldExtension)
                        Write-Log "-- Renaming: ${readmeFile} - ${newFileName}"
                        Move-Item -Path $readmeFile -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
                # Action - RenameLicences
                elseif ($action -eq [InstallAction]::RenameLicence) {
                    $installBaseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

                    $licenceFiles = Get-ChildItem -Path $targetPath -Filter licen*.*
                    foreach($licenceFile in $licenceFiles) {
                        $oldName = [System.IO.Path]::GetFileNameWithoutExtension($licenceFile)
                        $newFileName = Join-Path $targetPath ($installBaseName + "." + $oldName)
                        Write-Log "-- Renaming: ${licenceFile} - ${newFileName}"
                        Move-Item -Path $licenceFile -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
                # Action - RenameFAQ
                elseif ($action -eq [InstallAction]::RenameFAQ) {
                    $installBaseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

                    $faqFiles = Get-ChildItem -Path $targetPath -Filter faq*.*
                    foreach($faqFile in $faqFiles) {
                        $oldName = [System.IO.Path]::GetFileNameWithoutExtension($faqFile)
                        $newFileName = Join-Path $targetPath ($installBaseName + "-" + $oldName)
                        Write-Log "-- Renaming: ${faqFile} - ${newFileName}"
                        Move-Item -Path $faqFile -Destination $newFileName -Force -Verbose:$verbose
                    }
                }
            }

            #------------------------------------------------------------------------------------------------------------------------
            # Process each defined Option
            #------------------------------------------------------------------------------------------------------------------------

            # Option - RenameTarget
            if ($this.Parameters.ContainsKey([InstallParameter]::RenameTarget)) {
                $renameTargets = ($this.Parameters[[InstallParameter]::RenameTarget]).Split("|")
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
            # Option - ShortcutFilenames
            if ($this.Parameters.ContainsKey([InstallParameter]::ShortcutFilenames)) {
                $shellFolders = @{}
                $shellFolders["startmenu"]    = [Environment]::GetFolderPath("StartMenu")
                $shellFolders["desktop"]      = [Environment]::GetFolderPath("Desktop")
                $shellFolders["startup"]      = [Environment]::GetFolderPath("Startup")
                $shellFolders["programsmenu"] = (Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs").ToString()

                $shortcutPath = ""
                if ($this.Parameters.ContainsKey([InstallParameter]::ShortcutTarget)) {
                    $installTarget = $this.Parameters[[InstallParameter]::ShortcutTarget]

                    if ($installTarget.StartsWith("shell:")) {
                        $shellTarget = $installTarget.TrimStart("shell").TrimStart(":")

                        if ($shellFolders.ContainsKey($shellTarget)) {
                            $shortcutPath = $shellFolders[$shellTarget]
                        }
                        else {
                            Write-Log "-- ERROR: Invalid / Unknown Shortcut Target: ${installTarget}"
                        }
                    }
                }
                if ($this.Parameters.ContainsKey([InstallParameter]::ShortcutFolder)) {
                    $shortcutFolder = $this.Parameters[[InstallParameter]::ShortcutFolder]
                    $shortcutPath = Join-Path $shortcutPath $shortcutFolder
                }

                if ([string]::IsNullOrEmpty($shortcutPath)) {
                    $shortcutPath = $($shellFolders.Values)[0]
                }
                New-Folder $shortcutPath

                $shortcutTargets = ($this.Parameters[[InstallParameter]::ShortcutFilenames]).Split("|")
                foreach($shortcutTarget in $shortcutTargets) {
                    $shortcutFileNameAndName = $shortcutTarget.Split("=")
                    $fileName = $shortcutFileNameAndName[0]
                    $name = $shortcutFileNameAndName[1]

                    $targetFileNames = Get-ChildItem -Path $targetPath -Filter $fileName
                    foreach($targetFileName in $targetFileNames) {
                        $shortcutCommand = Join-Path $baseTargetFolder "bin" "shortcut32.exe"
                        $shortcutFileName = Join-Path $shortcutPath ($name + ".lnk")
                        $shortcutTargetFileName = $targetFileName.FullName
                        $arguments = "/F:""${shortcutFileName}"" /A:Create /T:""${shortcutTargetFileName}"""
                        Write-Log "-- Creating Shortcut: ${shortcutFileName} - ${shortcutTargetFileName}"
                        Invoke-ExecuteProcess $shortcutCommand $arguments $verbose
                    }
                }
            }
        }
    }
}

#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# App Data
$bannerLine     = [string]::new('-', 120)
$bannerPartLine = [string]::new('-', 40)

$defined_apps = @(
    # Command Line Apps
     [AppDefinition]::new("7za command",                    "Mandatory",  [OSType]::Any, "apps\7zip\x64",                                            "*.exe",                   "bin",                      [InstallType]::CopyFiles)
    ,[AppDefinition]::new("My Native Console Apps",         "Essentials", [OSType]::x64, "apps\martinsmith1968\NativeWindowsConsoleApplicationsCPP", "*.zip",                   "msbin",                    [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ))
    ,[AppDefinition]::new("My Legacy Console Apps",         "Essentials", [OSType]::Any, "apps\martinsmith1968\legacy",                              "*.*",                     "msbin",                    [InstallType]::CopyFiles)
    ,[AppDefinition]::new("GnuWin32",                       "Standard",   [OSType]::Any, "apps\GnuWin32",                                            "*.zip",                   "",                         [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "gnuwin32\*.*" ; [InstallParameter]::ExtractCustomArguments = "-r" })
    ,[AppDefinition]::new("OptimumX Console Apps",          "Standard",   [OSType]::x64, "apps\OptimumX",                                            "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ))
    ,[AppDefinition]::new("NirSoft Console Essentials",     "Standard",   [OSType]::Any, "apps\nirsoft\console",                                     "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ))
    ,[AppDefinition]::new("Fourmilab Crypto tools",         "Standard",   [OSType]::Any, "apps\fourmilab",                                           "*.zip",                   "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Stahlworks SFK",                 "Standard",   [OSType]::Any, "apps\stahlworks",                                          "sfk.zip",                 "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("FAR File Manager",               "Standard",   [OSType]::x32, "apps\far",                                                 "*x86*.7z",                "bin\far",                  [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("FAR File Manager",               "Standard",   [OSType]::x64, "apps\far",                                                 "*x64*.7z",                "bin\far",                  [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("VerPatch",                       "Standard",   [OSType]::Any, "apps\ddbug",                                               "*.zip",                   "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Micro Text Editor",              "Standard",   [OSType]::x32, "apps\micro",                                               "*win32*.zip",             "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Micro Text Editor",              "Standard",   [OSType]::x64, "apps\micro",                                               "*win64*.zip",             "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "micro.*" })
    ,[AppDefinition]::new("Nano Text Editor",               "Standard",   [OSType]::x32, "apps\nano",                                                "*win32*.zip",             "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes, [InstallAction]::RenameLicence, [InstallAction]::RenameFAQ ), @{ [InstallParameter]::ExtractCommand = "e" })
    ,[AppDefinition]::new("Nano Text Editor Syntax",        "Standard",   [OSType]::x32, "apps\nano",                                                "*win32*.zip",             "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "syntax\*" })
    ,[AppDefinition]::new("Nano Text Editor",               "Standard",   [OSType]::x64, "apps\nano",                                                "*win64*.zip",             "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes, [InstallAction]::RenameLicence, [InstallAction]::RenameFAQ ), @{ [InstallParameter]::ExtractCommand = "e" })
    ,[AppDefinition]::new("Nano Text Editor Syntax",        "Standard",   [OSType]::x64, "apps\nano",                                                "*win64*.zip",             "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "syntax\*" })
    ,[AppDefinition]::new("VerPatch",                       "Standard",   [OSType]::Any, "apps\ddbug",                                               "*.zip",                   "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Find and Replace Tool",          "Standard",   [OSType]::Any, "apps\fart",                                                "*.zip",                   "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("MiniTrue",                       "Standard",   [OSType]::Any, "apps\minitrue",                                            "*.zip",                   "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "*.exe" })
    ,[AppDefinition]::new("Info-ZIP",                       "Standard",   [OSType]::x32, "apps\info-zip",                                            "*win32*.zip",             "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Info-ZIP",                       "Standard",   [OSType]::x64, "apps\info-zip",                                            "*win64*.zip",             "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("XD 2 Markdown",                  "Developer",  [OSType]::Any, "apps\formix",                                              "*.zip",                   "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("AutoHotKey",                     "Developer",  [OSType]::Any, "apps\AutoHotKey",                                          "*.zip",                   "AutoHotKey",               [InstallType]::ExtractZip)
    ,[AppDefinition]::new("JSON Query tool",                "Standard",   [OSType]::x32, "apps\jq\x32",                                              "*.exe",                   "bin",                      [InstallType]::CopyFiles,  @{ [InstallParameter]::RenameTarget = "jq-*.exe=jq.exe" })
    ,[AppDefinition]::new("JSON Query tool",                "Standard",   [OSType]::x64, "apps\jq\x64",                                              "*.exe",                   "bin",                      [InstallType]::CopyFiles,  @{ [InstallParameter]::RenameTarget = "jq-*.exe=jq.exe" })
    ,[AppDefinition]::new("XML Query tool",                 "Standard",   [OSType]::Any, "apps\xq",                                                  "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes, [InstallAction]::RenameLicence ))
    ,[AppDefinition]::new("YAML Query tool",                "Standard",   [OSType]::x32, "apps\yq\x32",                                              "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes, [InstallAction]::RenameLicence ))
    ,[AppDefinition]::new("YAML Query tool",                "Standard",   [OSType]::x64, "apps\yq\x64",                                              "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes, [InstallAction]::RenameLicence ))
    ,[AppDefinition]::new("Naughter ShelExec",              "Standard",   [OSType]::x64, "apps\naughter",                                            "shelexec.zip",            "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "ReleaseU64C\*.exe" })
    ,[AppDefinition]::new("Naughter ShelExec",              "Standard",   [OSType]::x32, "apps\naughter",                                            "shelexec.zip",            "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "ReleaseUC\*.exe" })
    ,[AppDefinition]::new("Naughter StartX",                "Standard",   [OSType]::x64, "apps\naughter",                                            "startx.zip",              "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "ReleaseU64\*.exe" })
    ,[AppDefinition]::new("Naughter StartX",                "Standard",   [OSType]::x32, "apps\naughter",                                            "startx.zip",              "bin",                      [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "ReleaseU\*.exe" })
    ,[AppDefinition]::new("Microsoft File Checksum Tool",   "Standard",   [OSType]::Any, "apps\Microsoft\FileChecksumIntegrityVerifier",             "*.zip",                   "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Microsoft XSL Tool",             "Standard",   [OSType]::Any, "apps\Microsoft\msxsl",                                     "msxsl.exe",               "bin",                      [InstallType]::CopyFiles)
    ,[AppDefinition]::new("Microsoft SysInternals",         "Standard",   [OSType]::Any, "apps\Microsoft\SysInternals",                              "*.zip",                   "sysinternals",             [InstallType]::ExtractZip)
    ,[AppDefinition]::new("Microsoft Win2000 Resource Kit", "Standard",   [OSType]::Any, "apps\Microsoft\Win2000ResourceKit",                        "*.zip",                   "bin",                      [InstallType]::ExtractZip)
    ,[AppDefinition]::new("XmlStarlet",                     "Standard",   [OSType]::Any, "apps\xmlstarlet",                                          "*.zip",                   "bin",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "**\*.exe **\readme **\doc\*.txt" })

    # Wndows Apps
    ,[AppDefinition]::new("Window Extensions",              "Standard",   [OSType]::Any, "apps-win\martinsmith1968\WindowExtensions",                "*.zip",                   "mswin\WindowExtensions",   [InstallType]::ExtractZip, @{ [InstallParameter]::ShortcutFilenames = "WindowExtensions.exe=Window Extensions" ; [InstallParameter]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("QuickCalendar",                  "Standard",   [OSType]::Any, "apps-win\martinsmith1968\QuickCalendar",                   "*.zip",                   "mswin\QuickCalendar",      [InstallType]::ExtractZip, @{ [InstallParameter]::ShortcutFilenames = "QuickCalendar.exe=Quick Calendar" ; [InstallParameter]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("Metapad",                        "Standard",   [OSType]::Any, "apps-win\metapad",                                         "*.zip",                   "win",                      [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "metapad.exe=Metapad" }) ))
    ,[AppDefinition]::new("Notepad2",                       "Standard",   [OSType]::Any, "apps-win\notepad2",                                        "*.zip",                   "win",                      [InstallType]::ExtractZip, @( [InstallAction]::RenameLicence ), @{ [InstallParameter]::ShortcutFilenames = "notepad2.exe=Notepad 2" ; [InstallParameter]::ShortcutTarget = "shell:startmenu" ; [InstallParameter]::ShortcutFolder = "utils" })
    ,[AppDefinition]::new("Notepad3",                       "Standard",   [OSType]::Any, "apps-win\notepad3",                                        "*.zip",                   "win\Notepad3",             [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "Notepad3.exe=Notepad 3" }) ))
    ,[AppDefinition]::new("Wordpad",                        "Standard",   [OSType]::Any, "apps-win\Microsoft",                                       "wordpad*.zip",            "win\Wordpad",              [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "wordpad.exe=Wordpad" }) ))
    ,[AppDefinition]::new("Jarte",                          "Standard",   [OSType]::Any, "apps-win\jarte",                                           "jarte*.zip",              "win\jarte",                [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "jarte.exe=Jarte" }) ))
    ,[AppDefinition]::new(".NET Version Detector",          "Standard",   [OSType]::Any, "apps-win\DotNETVersionDetector",                           "*.zip",                   "win",                      [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "dotnetver.exe=NET Version Detector"  }) ))
    ,[AppDefinition]::new("Desktop OK",                     "Standard",   [OSType]::x64, "apps-win\SoftwareOK\x64",                                  "DesktopOK*.zip",          "win\SoftwareOK",           [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ExtractWildcard = "*.exe" ; [InstallParameter]::ShortcutFilenames = "DesktopOK*.exe=Desktop OK"  }) ))
    ,[AppDefinition]::new("FontView OK",                    "Standard",   [OSType]::x64, "apps-win\SoftwareOK\x64",                                  "FontView*.zip",           "win\SoftwareOK",           [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ExtractWildcard = "*.exe" ; [InstallParameter]::ShortcutFilenames = "FontViewOK*.exe=FontView OK"  }) ))
    ,[AppDefinition]::new("Desktop OK",                     "Standard",   [OSType]::x32, "apps-win\SoftwareOK\x32",                                  "DesktopOK*.zip",          "win\SoftwareOK",           [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ExtractWildcard = "*.exe" ; [InstallParameter]::ShortcutFilenames = "DesktopOK*.exe=Desktop OK" }) ))
    ,[AppDefinition]::new("TreeSize Free",                  "Standard",   [OSType]::Any, "apps-win\JAM-Software",                                    "*.zip",                   "win\TreeSize",             [InstallType]::ExtractZip, [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ExtractWildcard = "*.exe" ; [InstallParameter]::ShortcutFilenames = "TreeSize*.exe=TreeSize Free" }) ))
    ,[AppDefinition]::new("Topdesk",                        "Standard",   [OSType]::Any, "apps-win\SnadBoy",                                         "*.zip",                   "win\Snadboy",              [InstallType]::ExtractZip, @{ [InstallParameter]::ExtractWildcard = "*.exe" ; [InstallParameter]::ShortcutFilenames = "TopDesk*.exe=Topdesk" ; [InstallParameter]::ShortcutTarget = "shell:desktop" })
    ,[AppDefinition]::new("System Tray Menu",               "Standard",   [OSType]::Any, "apps-win\SystemTrayMenu",                                  "*.zip",                   "win\SystemTrayMenu",       [InstallType]::ExtractZip, @{ [InstallParameter]::ShortcutFilenames = "SystemTrayMenu.exe=System Tray Menu" ; [InstallParameter]::ShortcutTarget = "shell:startup" })
    ,[AppDefinition]::new("LogExpert",                      "Standard",   [OSType]::Any, "apps-win\LogExpert",                                       "*.zip",                   "win\LogExpert",            [InstallType]::ExtractZip, @( [InstallAction]::ClearTargetFolder ), [hashtable]( ApplyStandardShortcutMenu(@{ [InstallParameter]::ShortcutFilenames = "LogExpert.exe=Log Expert" }) ))
    ,[AppDefinition]::new("NirSoft - Registry Scanner",     "Standard",   [OSType]::Any, "apps-win\nirsoft",                                         "RegScanner*.zip",         "win\nirsoft",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ShortcutFilenames = "RegScanner*.exe=RegScanner" }) ))
    ,[AppDefinition]::new("NirSoft - HotKey List",          "System",     [OSType]::Any, "apps-win\nirsoft",                                         "hotkeyslist*.zip",        "win\nirsoft",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ShortcutFilenames = "hotkeyslist*.exe=Hot Keys List" }) ))
    ,[AppDefinition]::new("NirSoft - HotKey List",          "System",     [OSType]::Any, "apps-win\nirsoft",                                         "hotkeyslist*.zip",        "win\nirsoft",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ShortcutFilenames = "hotkeyslist*.exe=Hot Keys List" }) ))
    ,[AppDefinition]::new("HotKey Detective",               "System",     [OSType]::x32, "apps-win\ITachiLab\hotkey-detective",                      "hotkey-detective*.zip",   "win\nirsoft",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "x86\*" ; [InstallParameter]::ShortcutFilenames = "hotkey*.exe=Hot Key Detective" }) ))
    ,[AppDefinition]::new("HotKey Detective",               "System",     [OSType]::x64, "apps-win\ITachiLab\hotkey-detective",                      "hotkey-detective*.zip",   "win\nirsoft",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ExtractWildcard = "x64\*" ; [InstallParameter]::ShortcutFilenames = "hotkey*.exe=Hot Key Detective" }) ))
    ,[AppDefinition]::new("AlomWare Toolbox",               "System",     [OSType]::Any, "apps-win\Alomware",                                        "Toolbox*.zip",            "win\Toolbox",              [InstallType]::ExtractZip, @( [InstallAction]::RenameReadmes ), [hashtable]( ApplyStandardShortcutMenu( @{ [InstallParameter]::ExtractCommand = "e" ; [InstallParameter]::ShortcutFilenames = "Toolbox*.exe=AlomWare Toolbox" }) ))

    ,[AppDefinition]::new("Login Script",                   "Essentials", [OSType]::Any, "",                                                         "Login.cmd",               "",                         [InstallType]::None, @{ [InstallParameter]::ShortcutFilenames = "Login.cmd=Login Script" ; [InstallParameter]::ShortcutTarget = "shell:startup" })
)


#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
# Start
Write-Log $bannerLine
Write-Log "-- Started at ${startDateTime}"
Write-Log $bannerLine

# Validate
if ([string]::IsNullOrEmpty($targetFolder)) {
    $targetFolder = $PSScriptRoot
}
if ($verbose) {
    Write-Log "** Installing to: ${targetFolder}"
}
New-FolderIfNotExists $targetFolder
if (-Not (Test-Path $targetFolder)) {
    throw "Install path not found: ${targetFolder}"
}

if ($osType -eq [OSType]::Any) {
    $osType = Get-OSType
}
if ($verbose) {
    Write-Log "** Processing OS Type: ${osType}"
}

# Filter based on parameters
Write-Log "** Filtering: $($defined_apps.Count) apps"
$install_apps = @()
$index = 0
Write-Log "** Filtering: $($defined_apps.Count) apps"
foreach($defined_app in $defined_apps) {
    $index++

    $include = $False

    if ($defined_app.OSType -eq $osType -or $defined_app.OSType -eq [OSType]::Any) {
        $include = $True
    }
    if ($include) {
        if (-Not $groups.Contains($defined_app.GroupName)) {
            $include = $False
        }
    }

    if ($include) {
        if ($verbose) {
            Write-Log "** Including: [$($defined_app.OSType)] $($defined_app.Id)"
        }
        $install_apps += $defined_app
    }
}

# Install Apps
Push-Location $targetFolder

Write-Log "** Installing: $($install_apps.Count) apps"
$index = 0
foreach($app in $install_apps) {
    $index++
    Write-Log $bannerLine
    Write-Log "-- ${index}: $($app.Id)"

    if ($dryRun) {
        Write-Log "-- DRY RUN: $($app.Id) --> $($app.TargetPath)"
    } else {
        $app.Install($targetFolder, $verbose, $debug)
    }
}

# Modify PATH
if ($modifyPath) {
    # Add target directories to PATH
    Write-Log $bannerLine
    Write-Log "-- Building new PATHs"

    $utilsPaths = @()
    $utilsPaths += (Join-Path $targetFolder "cmd")
    $utilsPaths += (Join-Path $targetFolder "bin")
    $utilsPaths += (Join-Path $targetFolder "msbin")
    $utilsPaths += (Join-Path $targetFolder "mswin")
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
    Write-Log $bannerPartLine
    Write-Log "Old PATH : ${existingPath}"
    Write-Log-All ($existingPath.split(";"))
    Write-Log ""
    Write-Log $bannerPartLine
    Write-Log "New PATH : ${newPathValue}"
    Write-Log-All ($newPathValue.split(";"))
    [System.Environment]::SetEnvironmentVariable('PATH', $newPathValue, [System.EnvironmentVariableTarget]::User)
}

# Complete
Write-Log
Write-Log $bannerLine
Write-Log "-- Success !!"
Write-Log $bannerLine
Write-Log
Write-Log "Log complete: ${logFileName}"

Pop-Location
