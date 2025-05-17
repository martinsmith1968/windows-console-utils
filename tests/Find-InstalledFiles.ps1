class InstalledFile {
    [string] $fileName
    [int] $fileSize

    InstalledFile([string]$name, [int]$size) {
        $this.fileName = $name
        $this.fileSize = $size
    }

    InstalledFile([System.IO.FileInfo]$fileInfo) {
        $this.fileName = $fileInfo.Name
        $this.fileSize = $fileInfo.Length
    }
}

function Find-InstalledFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Pattern = '*'
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "The specified path does not exist: $Path"
        return
    }

    $items = @()
    foreach ($file in Get-ChildItem -Path $Path -Filter $Pattern -Recurse -File) {
        $items += [InstalledFile]::new($file)
    }

    return $items
}

$files_bin = Find-InstalledFiles -Path "C:\utils\bin"
$files_msbin = Find-InstalledFiles -Path "C:\utils\msbin"
