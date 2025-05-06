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
    [int32]$threshold = 50MB
)

. $PSScriptRoot\Include-Scripts.ps1

$items = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.z01" -File
Write-Host "Found $($items.count) candidate files"

$index = 0
if ($items.Count -gt 0) {
    foreach($item in $items) {
        ++$index
        
        $parts = Get-ChildItem -Path $item.Directory -Filter "$($item.BaseName)*" -File | Sort-Object Name

        Write-SeparatorLine
        Write-Host "${index}: File: $($item.BaseName) [$($parts.Count) parts]" -ForegroundColor Yellow

        $partIndex = 0
        foreach ($part in $parts) {
            ++$partIndex
            Write-Host "${index}.${partIndex}: $($part.FullName) - $($part.Length)"
        }
    }
}

exit 0

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
