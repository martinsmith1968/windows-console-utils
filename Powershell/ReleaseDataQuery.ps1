<#
.SYNOPSIS
Apply SQL Script to a database

.DESCRIPTION
Apply SQL Script to a database

.PARAMETER fileName
The script file name to use

.PARAMETER server
The hostname of the SQL Server. Defaults to (local)

.PARAMETER database
The database to apply the scripts to

.PARAMETER loginId
The login Id to use when connecting

.PARAMETER loginPassword
The password for the login Id to use when connecting
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("c")]
	[string]$command,
	
    [Alias("t")]
	[string]$teamName,
	
    [Alias("p")]
	[string]$personName,
	
    [Alias("r")]
	[string]$releaseName,
	
    [Alias("s")]
	[string]$serviceBusEntity,
	
    [Alias("root")]
	[string]$releaseDataRoot = "C:\\dev\\cbg\\ReleaseData", # TODO

    [Alias("u")]
    [bool]$useRemoteVersion = $False
)

enum CommandType {
    Person
    Team
    Release
}

class TeamMember
{
    [string] $Name
    [string] $EmailAddress
    [string] $EmployeeType
    [string] $Level
}

class Team
{
    [string] $TeamName
    [string] $AzureDevopsAreaPath
    [string] $TeamWikiLocation
    [TeamMember[]] $TeamMembers
}

function Write-Hashtable {
    param(
        [hashtable]$hashTable
    )

    $maxKeyLength = ($hashTable.Keys | Measure-Object -Maximum -Property Length).Maximum

    foreach ($h in $hashTable.Keys) {
        $key = $h.PadRight($maxKeyLength, ' ')
        Write-Host "$key : $($hashTable.$h)"
    }
}

function Find-ReleaseDataPerson {
    param(
        [Parameter(Mandatory=$True)]
        [string]$personName
    )

    $relativeFolder = "Teams"
    $path = [System.IO.Path]::Join($releaseDataRoot, $relativeFolder)

    $fileNames = Get-ChildItem -Path $path -Filter *.yaml

    $count = 0
    foreach($file in $fileNames) {
        $text = Get-Content -Path $file
        $team = $text | ConvertFrom-Yaml
        $members = $team.TeamMembers
        $foundMembers = $members | Where-Object { $_.Name -like $personName }
        if ($foundMembers.Count -gt 0) {
            Write-Host
            Write-Host "************************************************************"
            Write-Host "Team:" $team.TeamName

            foreach($teamMember in $foundMembers) {
                ++$count
                Write-Host
                Write-Hashtable $teamMember
            }
        }
    }

    Write-Host
    Write-Host "${count} results found"
}

function Find-ReleaseDataTeam {
    param(
        [Parameter(Mandatory=$True)]
        [string]$teamName
    )

    $relativeFolder = "Teams"
    $path = [System.IO.Path]::Join($releaseDataRoot, $relativeFolder)

    $fileNames = Get-ChildItem -Path $path -Filter *$teamName*.yaml

    $count = 0
    foreach($file in $fileNames) {
        ++$count
        $text = Get-Content -Path $file
        $team = $text | ConvertFrom-Yaml

        Write-Host
        Write-Host "************************************************************"
        Write-Host "Team:" $team.TeamName

        $members = $team.TeamMembers
        foreach($teamMember in $members) {
            Write-Host
            Write-Hashtable $teamMember
        }
    }

    Write-Host
    Write-Host "${count} results found"
}

function Find-ReleaseDataRelease {
    param(
        [Parameter(Mandatory=$True)]
        [string]$releaseName
    )

    $path = [System.IO.Path]::Join($releaseDataRoot, "DeploymentManifests", "BankingCore.yaml")
    $text = Get-Content -Path $path

    $deploymentGroups = $text | ConvertFrom-Yaml

    $allReleases = ($deploymentGroups["DeploymentGroups"] | Where-Object { $_.Name -eq "Builds" } | Select-Object -First 1).BuildDefinitions

    #$releases = $allReleases | Where-Object { $_.BuildDefinitionName -like $releaseName }

    $count = 0
    foreach($release in $allReleases) {
        if ($release.BuildDefinitionName -like $releaseName) {
            ++$count
            Write-Host
            Write-Hashtable $release
        }
    }

    Write-Host
    Write-Host "${count} results found"
}


# ---------- START
if ([string]::IsNullOrEmpty($releaseDataRoot)) {
    $ReleaseDataRoot = $PSScriptRoot
}

$commandType = [CommandType].Release

try {
    $commandType = [CommandType]$command
}
catch {
    $values = [string]::Join(", ", [Enum]::GetNames([CommandType]))
    Write-Error "Invalid Command : '${command}' (Valid options: $values)"
    exit
}

try {
    switch ($commandType) {
        ([CommandType]::Person) {
            if ([string]::IsNullOrEmpty($personName)) {
                throw "PersonName must be specified"
            }

            Find-ReleaseDataPerson $personName
        }
        ([CommandType]::Team) {
            if ([string]::IsNullOrEmpty($teamName)) {
                throw "TeamName must be specified"
            }

            Find-ReleaseDataTeam $teamName
        }
        ([CommandType]::Release) {
            if ([string]::IsNullOrEmpty($releaseName)) {
                throw "ReleaseName must be specified"
            }

            Find-ReleaseDataRelease $releaseName
        }
    }
}
catch {
    Write-Error "Error occurred during: '${command}' - ${PSItem}"
    Write-Host $PSItem
    exit
}
