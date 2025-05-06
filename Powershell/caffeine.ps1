$wsh = New-Object -ComObject Wscript.Shell
WHILE($TRUE){
    $wsh.SendKeys("{SCROLLLOCK}")
    $wsh.SendKeys("{SCROLLLOCK}")
	# Write-Host "Sleeping..."
    START-SLEEP -Seconds 60
}
