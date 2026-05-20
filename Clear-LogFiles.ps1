<#
.SYNOPSIS
    Show all the large file parts that have been split
.DESCRIPTION
    This script checks the size of files in the source directory and throws an error if any file exceeds the specified threshold size.
    The threshold size is set to 50MB by default, but can be changed by modifying the $threshold variable.    
.PARAMETER threshold
    The maximum file size allowed in bytes. Default is 50MB (52428800 bytes).
.EXAMPLE
    .\Verify-SourceFileSizes.ps1 -threshold 100MB
    This command will check for files larger than 100MB in the source directory.
.NOTES
    Author: Martin Smith
    Date:   2024-01-04
#>

param (
    [Boolean]$remove = $True
)

. $PSScriptRoot\Include-Scripts.ps1

$ErrorActionPreference = "Stop"

$items = Get-ChildItem $PSScriptRoot -Filter *.log -File | Sort-Object CreationTime -Descending

Write-Host "Found $($items.count)"
$index = 0
foreach($item in $items) {
    ++$index
    Write-Host "${index}: $($item.FullName) - $($item.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"))" -NoNewline

    try {
        if ($remove) {
            Remove-Item $item.FullName -Force -ErrorAction Continue
            Write-Host " - Deleted" -ForegroundColor Green
        } else {
            Write-Host " - Skipped" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host " - Failed to delete" -ForegroundColor Red
        Write-Host "  " + $_.Exception.Message -ForegroundColor Red
    }
}
