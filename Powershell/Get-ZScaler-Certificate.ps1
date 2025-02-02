$cert = Get-ChildItem Cert:\LocalMachine\Root\ | where Subject -like "*zscaler*"

$text = "-----BEGIN CERTIFICATE-----"
$text = $text + "`n" + [convert]::ToBase64String($cert.RawData) -replace '.{64}', "`$&`n"
$text = $text + "`n-----END CERTIFICATE-----"
$text | Set-Content C:\Data\zscaler.cer -Encoding Ascii
