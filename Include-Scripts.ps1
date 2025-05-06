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

function Add-ContentIfNotPresent([string] $path, [string] $value) {
    $content = Get-Content -Path $path -ErrorAction SilentlyContinue
    if (-not ($content -contains $value)) {
        Add-Content -Path $path -Value $value
    }
}
