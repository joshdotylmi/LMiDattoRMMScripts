function write-DRMMDiag ($messages) {
    write-host  '<-Start Diagnostic->'
    foreach ($Message in $Messages) { $Message }
    write-host '<-End Diagnostic->'
} 
function write-DRRMAlert ($message) {
    write-host '<-Start Result->'
    write-host "Alert=$message"
    write-host '<-End Result->'
}


$buildvhdxstoragevolumes = $((Get-VM|Get-VMHardDiskDrive | ForEach-Object {($_.Path).substring(0,1)}|Sort-Object -Unique)) 
$CurrentVMStorageState = (Get-VM|Get-VMHardDiskDrive | ForEach-Object {Get-Vhd -Verbose $_.Path }| select path,@{label=’Letter’;expression={($_.Path|ft -HideTableHeaders|out-string).substring(0,1)}},@{label=’Size(GB)’;expression={$_.size/1GB –as [int]}})

foreach ($volume in $buildvhdxstoragevolumes) { 
$sum = (($CurrentVMStorageState |Where-Object {$_.Letter -like "$volume"})."Size(GB)"| Measure-Object -Sum).sum
$physicalvolumesize=(Get-Volume -DriveLetter $volume).Size/1GB

$result += "Currently $volume drive has  $([Math]::Truncate($sum/$physicalvolumesize*100))% provisioned "
 write-host "Currently $volume drive has  $([Math]::Truncate($sum/$physicalvolumesize*100))% provisioned"
if ($sum -gt $physicalvolumesize) {
    $createdattoalert += "Currently $volume drive has  $([Math]::Truncate($sum/$physicalvolumesize*100))% provisioned"
   
write-host hey $volume is overprovisioned btw

}
}
if ($createdattoalert -ne $null){
    write-host $createdattoalert
    write-DRRMAlert "HyperV Host $env:computername is currently over provisioned"
    write-DRMMDiag "$createdattoalert $result"
    exit 1
} else {
    write-DRRMAlert "HyperV Host $env:computername healthy"
    write-DRMMDiag $result
}
