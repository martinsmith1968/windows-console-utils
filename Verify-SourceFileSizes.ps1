<#
.SYNOPSIS
    Verify the files in the source directory are not larger than a threshold size
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
    [int32]$threshold = 50MB
)

. $PSScriptRoot\Include-Scripts.ps1

$items = Get-LargeFiles -threshold $threshold
Write-Host "Found $($items.count) candidate files larger than $($threshold / 1MB)MB"

$index = 0
if ($items.Count -gt 0) {
    Write-SeparatorLine
    foreach($item in $items) {
        ++$index
        Write-Host "${index}: $($item.FullName) - $($item.Length)"
    }
}

if ($index -gt 0) {
    Write-SeparatorLine
    Write-Host "Failure" -ForegroundColor Red -NoNewline
    Write-Host " - ${index}" -ForegroundColor Yellow -NoNewline
    Write-Host " Invalid files found"
}
else {
    Write-Host "Success" -ForegroundColor Green -NoNewline
    Write-Host " - No Invalid files found"
}
