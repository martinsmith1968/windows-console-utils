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
    [Alias("f")]
	[string]$fileName,
	
    [Alias("s")]
	[string]$server = "(local)",
	
    [Alias("d")]
    [Parameter(Mandatory=$true)]
	[string]$database,
	
    [Alias("id")]
	[string]$loginId = "",
	
    [Alias("pwd")]
	[string]$loginPassword = ""
)

function DetectTrusted([string]$loginId)
{
	if ([string]::IsNullOrEmpty($loginId))
	{
		return $true
	}
	else
	{
		return $false
	}
}

function BuildLoginSwitches([Boolean]$trusted, [string]$id, [string]$password)
{
	if ($trusted)
	{
		return "-E";
	}
	else
	{
		return '-U "' + $id + '" -P "' + $password + '"';
	}
}

if (!(Test-Path $fileName))
{
    Write-Host "File does not exist - $fileName"
    exit
}

$trusted = (DetectTrusted $loginId)

$loginSwitches = (BuildLoginSwitches $trusted $loginId $loginPassword)
$sqlcmd = 'SQLCMD -S "' + $server + '" -d "' + $database + '" ' + $loginSwitches + ' -i "' + $fileName + '"'

Write-Verbose "SQLCMD: $sqlcmd"

Write-Host "Applying to : $server"
Invoke-Expression $sqlcmd
