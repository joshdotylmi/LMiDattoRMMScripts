#$env:UDFLocalAdministratorsGroup="26"

$LocalAdministratorsGroupString = ((get-localGroupMember -Group Administrators).Name|out-string).trim()

New-ItemProperty "HKLM:\SOFTWARE\CentraStage" -Name "Custom$env:UDFLocalAdministratorsGroup" -PropertyType string -Value $LocalAdministratorsGroupString -Force