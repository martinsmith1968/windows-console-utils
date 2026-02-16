<#
.SYNOPSIS
    Split and compress large files in the source directory into smaller parts.
.DESCRIPTION
    This script locates files in the source directory and splits them into smaller parts
    if they exceed the specified size threshold.
.PARAMETER threshold
    The maximum file size allowed in bytes. Default is 100MB (104857600 bytes).
    Although GitHub complains about files over 50MB
.PARAMETER threshold
    The maximum split file size allowed in bytes. Default is 25MB (26214400 bytes).
.EXAMPLE
    .\Split-LargeFiles.ps1 -threshold 100MB -maxSplitSize 50MB
    This command will check for files larger than 100MB in the source directory.
    and spluit them into smaller parts of 50MB each.
.NOTES
    Author: Martin Smith
    Date:   2024-01-04
#>

param (
    [int32]$threshold = 50MB,
    [int32]$maxSplitSize = 25MB,
    [switch][bool]$useZipOnPath = $false
)

. $PSScriptRoot\Include-Scripts.ps1

$command = Join-Path $PSScriptRoot "bin" "zip.exe"
if (!(Test-Path $command -PathType Leaf)) {
    $severity = "ERROR"
    $importance = "must"
    $exit = $true

    if ($useZipOnPath) {
        $severity = "WARNING"
        $importance = "should"
        $exit = $false

        $command = [System.IO.Path]::GetFileName($command)
    }

    Write-Host "${severity}: ${command} not found - UTILS ${importance} be installed first"
    if ($exit) {
        exit 1
    }
}

$candidates = Get-LargeFiles -threshold $threshold -file_extension "*.zip"
Write-Host "Found $($items.count) candidate files larger than $($threshold / 1MB)MB"

$items = @()
foreach($candidate in $candidates) {
    Push-Location $candidate.Directory
    
    $include = $True

    if ($include -And (Test-Path -Path ".gitkeep")) {
        $include = $False
        Write-Host "Skipping $($candidate.FullName) - .gitkeep file found in directory"
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

$splitSizeText = "$($maxSplitSize / 1MB)m"

$index = 0
foreach($item in $items) {
    ++$index
    Write-SeparatorLine
    Write-Host "${index}: $($item.FullName) - $($item.Length)"
    
    Push-Location $item.Directory
    
    & $command $item.FullName --out "$($item.Name)-split$($item.Extension)" -q -s $splitSizeText
    
    Add-ContentIfNotPresent -Path ".gitignore" -Value "$($item.Name)"

    Pop-Location
}

Write-SeparatorLine

$index = 0
foreach($item in $items) {
    ++$index
    Write-Host "${index}: $($item.FullName) - $($item.Length)"
}
Write-Host "${index} - files split"
