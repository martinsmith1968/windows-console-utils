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
    [string]$sitename = '*'
)

Import-Module Webadministration

function ListSites([string]$sitename)
{
    # Get-ChildItem -Path IIS:\Sites | ?{$_.Name -like $sitename}
    Get-Website | where {$_.Name -like $sitename} | Format-Table -Autosize
}

if ( $command -eq 'list' -Or $command -eq 'l'  )
{
    ListSites ($sitename)
}

if ( $command -eq 'start' -Or $command -eq 'a' )
{
    Start-Website $sitename
    ListSites ($sitename)
}

if ( $command -eq 'stop' -Or $command -eq 'o' )
{
    Stop-Website $sitename
    ListSites ($sitename)
}

if ( $command -eq 'restart' -Or $command -eq 'r' )
{
    Stop-Website $sitename
    Start-Website $sitename
    ListSites ($sitename)
}
