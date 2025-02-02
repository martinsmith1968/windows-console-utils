<#
.SYNOPSIS
    Control Ticketer services
.DESCRIPTION
.PARAMETER command
    The command to execute ( (l)ist / st(a)rt / st(o)p / (r)estart )
.PARAMETER servicename
    Specifies the name or names of services to target (via wildcard)
    Defaults to 'ticketer*'
.EXAMPLE
    C:\PS>
    tktr list
    tktr start              -- Starts all ticketer* services
    tktr start TicketerBo   -- Starts only TicketerBo service
    tktr stop               -- Stops all ticketer* services
.NOTES
    Author: Martin Smith
    Date:   December 13, 2016
#>
param (
    [string]$command = "list",
    [string]$servicename = 'ticketer*'
)

function ListServices([string]$servicename)
{
    # Get-Service $servicename
    Get-WmiObject win32_service | ?{$_.Name -like $servicename} | select Name, ProcessId, PathName
}

if ( $command -eq 'list' -Or $command -eq 'l'  )
{
    ListServices ($servicename)
}

if ( $command -eq 'start' -Or $command -eq 'a' )
{
    Start-Service $servicename
    ListServices ($servicename)
}

if ( $command -eq 'stop' -Or $command -eq 'o' )
{
    Stop-Service $servicename
    ListServices ($servicename)
}

if ( $command -eq 'restart' -Or $command -eq 'r' )
{
    Stop-Service $servicename
    Start-Service $servicename
    ListServices ($servicename)
}
