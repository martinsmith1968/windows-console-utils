$registryPath = "HKCU:\Software\Microsoft\Command Processor"
$Name = "AutoRun"
$value = "C:\Utils\cmd\AutoRun.cmd"

New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null

