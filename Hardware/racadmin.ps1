$omeServer = "https://csklx007.corp.pjc.com"
$omeUsername = "admin"
$omePassword = "Ngw58@Kc"

# Create a credential object for authentication
$credential = New-Object PSCredential -ArgumentList @($omeUsername, (ConvertTo-SecureString -String $omePassword -AsPlainText -Force))

$result = Invoke-RestMethod -Method Get -Uri "https://csklx007.corp.pjc.com/api/DeviceService/Devices?top=10000" -Credential $Credential

$ips = $result.value.DeviceManagement.NetworkAddress

$ErrorActionPreference = "Stop"
$errors = @()

$ips = Get-Content C:\temp\ips.txt

foreach ($ip in $ips){
try{
$ip
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p "seKmYF45O7#1Pe94$!m" --nocertwarn set idrac.syslog.SysLogEnable Enabled

& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p "seKmYF45O7#1Pe94$!m" --nocertwarn set idrac.syslog.server1 10.128.102.37

& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p "seKmYF45O7#1Pe94$!m" --nocertwarn set idrac.syslog.Port 13019
}
catch{

$error += $ip

}

}



foreach ($ip in $ips){
$ip
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p "seKmYF45O7#1Pe94$!m" --nocertwarn get idrac.syslog.server1
}
