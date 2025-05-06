$ErrorActionPreference = "Stop"

$items = Get-ChildItem $PSScriptRoot -Filter *.log -File | Sort-Object CreationTime -Descending

Write-Host "Found $($items.count)"
$index = 0
foreach($item in $items) {
    ++$index
    Write-Host "${index}: $($item.FullName) - $($item.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"))" -NoNewline

    try {
        Remove-Item $item.FullName -Force -ErrorAction Continue
        Write-Host " - Deleted" -ForegroundColor Green
    }
    catch {
        Write-Host " - Failed to delete" -ForegroundColor Red
        Write-Host "  " + $_.Exception.Message -ForegroundColor Red
    }
}
