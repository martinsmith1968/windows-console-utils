Push-Location $PSScriptRoot

$temp_path = Join-Path -Path $PSScriptRoot -ChildPath "temp"
if (Test-Path -Path $temp_path) {
    Remove-Item -Path $temp_path -Recurse -Force
}
New-Item -Path $temp_path -ItemType Directory | Out-Null

$files = Get-ChildItem -Path . -Filter *.exe
Write-Host "Found $($files.Count) files..."

foreach ($file in $files) {
    Write-Host "Preparing $($file.Name)..."
    
    $raw_parts = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) -split '-'
    $parts = @()
    foreach ($part in $raw_parts) {
        if ($part -eq "x86_64") {
            break
        }
        $parts += $part
    }

    $target_name = ($parts -join '-') + ".exe"
    $target_path = Join-Path -Path $temp_path -ChildPath $target_name

    if ($file.Name -eq $target_name) {
        Write-Host "WARN: Skipping $($file.Name) - FileName not changed..." -ForegroundColor Yellow
        continue
    }
    if (Test-Path -Path $target_path) {
        Write-Host "WARN: File $($target_name) already exists, skipping..." -ForegroundColor Yellow
        continue
    }
    Copy-Item -Path $file.FullName -Destination $target_path
}

$copied_files = Get-ChildItem -Path $temp_path -Filter *.exe 
if ($copied_files.Count -gt 0) {
    Write-Host "Copied $($copied_files.Count) files to $temp_path" -ForegroundColor Green

    Compress-Archive -Path $temp_path\* -DestinationPath "$PSScriptRoot\mq.zip" -Force
} else {
    Write-Host "WARN: No files copied to $temp_path" -ForegroundColor Yellow
}

Remove-Item -Path $temp_path -Recurse -Force

Pop-Location
