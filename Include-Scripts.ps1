function Get-LargeFiles([int32] $threshold) {
    $foldersToExclude = Get-ChildItem $PSScriptRoot -Directory | Where-Object { Test-Path -Path (Join-Path $_.FullName ".gitkeep") }
    $excludeList = $foldersToExclude | Join-String -Property Name -Separator ","

    $items = Get-ChildItem $PSScriptRoot -Exclude ${excludeList} | Get-ChildItem -Recurse -File | Where-Object {
        $_.Length -gt $threshold
    }

    return $items
}

function Write-SeparatorLine([System.ConsoleColor] $color = [System.ConsoleColor]::White) {
    $length = $Host.UI.RawUI.WindowSize.Width - 1
    $line = "-" * $length
    Write-Host $line -ForegroundColor $color
}

function Get-FileHasContent([string] $path, [string] $line) {
    if (!(Test-Path $path)) {
        return $false
    }

    $content = Get-Content -Path $path -ErrorAction SilentlyContinue

    return $content -contains $line
}

function Test-FileExists([string] $path, [bool]$checkParents = $true) {
    $filename = [System.IO.Path]::GetFileName($path)
    $dir = [System.IO.Path]::GetDirectoryName($path)
    if (!$dir) {
        $dir = [System.IO.Directory]::GetCurrentDirectory()
        $path = Join-Path $dir $filename
    }

    do {
        $test_filename = Join-Path $dir $filename
        if (Test-Path -Path $test_filename -PathType Leaf) {
            return $test_filename
        }

        $dir = (Get-Item $dir).Parent.FullName
    } while ($checkParents -and $dir -And $path -and $dir -ne [System.IO.Path]::GetPathRoot($path))

    return $null
}

function Add-ContentIfNotPresent([string] $path, [string] $value, [string] $additionalValue = $null) {
    $content = Get-Content -Path $path -ErrorAction SilentlyContinue

    $valueExists = $content -contains $value
    if ($additionalValue -and -not $valueExists) {
        $valueExists = $content -contains $additionalValue
    }

    if (-not $valueExists) {
        Write-Host "Adding to ${path}: ${value}"
        Add-Content -Path $path -Value $value
    }
}
