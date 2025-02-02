Param
(
  $computerName = $env:COMPUTERNAME
)

Get-WmiObject -Class win32_bios -ComputerName $computerName
