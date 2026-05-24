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

$candidates = Get-LargeFiles -threshold $threshold
Write-Host "Found $($items.count) candidate files larger than $($threshold / 1MB)MB"

$items = @()
foreach($candidate in $candidates) {
    Push-Location $candidate.Directory
    
    $include = $True

    if ($include) {
        $path_to_check = $candidate.Directory

        do {
            $file_to_check = Join-Path $path_to_check ".gitkeep"
            if (Test-Path -Path $file_to_check) {
                $include = $False
                Write-Host "Skipping $($candidate.FullName) - .gitkeep file found in directory: $($path_to_check.FullName)"
            }
            $path_to_check = $path_to_check.Parent
        } while ($path_to_check.FullName -ne $path_to_check.Root.Target.FullName)
    }

    if ($include -And (Test-Path -Path ".gitignore")) {
        $ignored_lines = Get-Content -Path ".gitignore"
        if ($ignored_lines -contains $candidate.Name) {
            $include = $False
            Write-Host "Skipping $($candidate.FullName) - already in .gitignore"
        }
    }
    
    if ($include) {
        $items += $candidate
    }

    Pop-Location
}

$index = 0
if ($items.Count -gt 0) {
    Write-SeparatorLine
    foreach($item in $items) {
        ++$index
        Write-Host "${index}: $($item.FullName) - $($item.Length.ToString('#,##0'))" -ForegroundColor Yellow
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
