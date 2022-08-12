function write-DRMMDiag ($messages) {
    write-host  '<-Start Diagnostic->'
    foreach ($Message in $Messages) { $Message }
    write-host '<-End Diagnostic->'
} function write-DRRMAlert ($message) {
    write-host '<-Start Result->'
    write-host "Alert=$message"
    write-host '<-End Result->'
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
if (Get-PackageProvider -Name NuGet) {write-host "Nuget is installed"} else {
Find-PackageProvider nuget | Install-PackageProvider -ForceBootstrap -force -scope AllUsers  -Verbose
Install-PackageProvider -Name NuGet -Force -Verbose}


$ModulesInstalled = (Get-Module -ListAvailable -All).Name

if ($ModulesInstalled -contains "PowershellGet"){ Write-Host "PowerShellGet Module exists"} 
else {

    Install-Module -Name PowerShellGet -Force -Scope AllUsers -AllowClobber -Verbose
    Write-Host "Installing PowerShellGet"
}

#if ($ModulesInstalled -contains packagementmanagement -All){ Write-Host "packagementmanagement Module exists"} 
#else {
#
#    Install-Module -Name packagementmanagement -Force -Scope AllUsers -AllowClobber -Verbose
#    Write-Host "Installing PS Packagemanagement"
#}


if ($ModulesInstalled -contains "PSWindowsUpdate"){ Write-Host " PSWindowsUpdate Module exists"} 
else {

    Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers -AllowClobber -Verbose
    Write-Host "Installing PSWindowsUpdate"
}


#$env:usrUDF1 = 19
#$env:usrDays = 30


$date = (Get-WUList -IsInstalled).LastDeploymentChangeTime |Sort-Object -Descending |Select-Object -First 1

$pastdate = (Get-date).AddDays([int]$env:usrDays*-1)
$LastPatchInfo=  Get-date $date -format 'MM/dd/yyyy'



if ([int]$env:usrUDF1 -and [int]$env:usrUDF1 -match '^\d+$') {
    #is it between 1 and 30?
    if ([int]$env:usrUDF1 -ge 1 -and [int]$env:usrUDF1 -le 30) {
            New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name Custom$env:usrUDF1 -Value "$LastPatchInfo" -Force | Out-Null
            write-host "Value written to User-defined Field $env:usrUDF1`."
    } else {
        write-host "User-defined Field value must be an integer between 1 and 30."
    }
} else {
    write-host "User-defined field value invalid or not specified - not writing results to a User-defined field."
}



if ($date -lt $pastdate) {
    write-DRRMAlert "Last Patch Ran Over $env:usrDays Days Ago"
  #  exit 1 
}
else { 
    write-DRRMAlert "Healthy" 
    write-DRMMDiag $LastPatchInfo
}