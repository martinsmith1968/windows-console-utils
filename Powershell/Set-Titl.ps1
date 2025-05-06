param(
    [string]$code
   ,[string]$prefix = ""
   ,[string]$suffix = ""
)

$script_directory = Get-Item $PSScriptRoot
$current_directory = Get-Item $PWD

$title = ""

switch ($code) {
    "p" { $title = $current_directory.FullName}
    "n" { $title = $current_directory.Name }
    "e" { $title = $current_directory.Extension }
    "sp" { $title = $script_directory.FullName }
    "sn" { $title = $script_directory.Name }
    "se" { $title = $script_directory.Extension }
    Default { $title = $code }
}

if ([string]::IsNullOrEmpty($title)) {
    Write-Host -ForegroundColor Red "ERROR: Title is required"
    exit 1
}

$title = $prefix + $title + $suffix

$host.ui.RawUI.WindowTitle = $title
