$ErrorActionPreference = "Stop"

$threshold = 50MB

$items = Get-ChildItem $PSScriptRoot -Recurse -File | Where-Object {
    $_.Length -gt $threshold
}

Write-Host "Found $($items.count)"
$index = 0
foreach($item in $items) {
    ++$index
    Write-Host "${index}: $($item.FullName) - $($item.Length)"
    
    Push-Location $item.Directory
    
    & zip $item.Name --out "$($item.Name)-split$($item.Extension)" -s 25m
    
    Pop-Location
}
