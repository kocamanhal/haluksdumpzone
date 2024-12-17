$omeServer = "https://csklx007.corp.pjc.com"
$omeUsername = "admin"
$omePassword = "Ngw58@Kc"
$dracpass = "seKmYF45O7#1Pe94$!m"

# Create a credential object for authentication
$credential = New-Object PSCredential -ArgumentList @($omeUsername, (ConvertTo-SecureString -String $omePassword -AsPlainText -Force))

$result = Invoke-RestMethod -Method Get -Uri "https://csklx007.corp.pjc.com/api/DeviceService/Devices?top=10000" -Credential $Credential

$ips = $result.value.DeviceManagement.NetworkAddress

$ErrorActionPreference = "Stop"

#set new root password
$ips = "10.128.42.177", "10.128.42.178", "10.128.42.179", "10.128.42.180", "10.128.42.181", "10.128.42.182"

foreach ($ip in $ips){
    $ip
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p "S1GNKwvN=m{G" --nocertwarn set idrac.users.2.password $dracpass
}

$ips = Get-Content C:\temp\ips.txt


#set syslog
foreach ($ip in $ips){
try{
$ip = "10.128.42.182"
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set idrac.syslog.SysLogEnable Enabled

& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set idrac.syslog.server1 10.128.102.37

& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set idrac.syslog.Port 13019
}
catch{

$error += $ip

}

}

#check syslog
foreach ($ip in $ips){
$ip
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn get idrac.syslog.server1
}


#set DNS servers
foreach ($ip in $ips){
    $ip
    & 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ipv4.dns1 10.20.0.100
    & 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ipv4.dns2 10.50.96.60

}

#set DNS domain name
foreach ($ip in $ips){
    $ip
    & 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.NIC.DNSDomainName 'corp.pjc.com'
}

#set DNS Rac name

& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r 10.128.42.182 -u "root" -p $dracpass --nocertwarn set iDRAC.NIC.DNSRacName cskvs012e-drac


#activate directoty services on the idrac
foreach ($ip in $ips){
    $ip
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ActiveDirectory.Enable 1
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ActiveDirectory.DomainController1 10.20.0.100
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ActiveDirectory.DomainController2 10.50.96.60
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ActiveDirectory.Schema 2
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ADGroup.1.Name ServerSSMAdmins
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ADGroup.1.Domain corp.pjc.com
#0x1ff is administrator
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.ADGroup.1.Privilege 0x1ff
& 'C:\Program Files\Dell\SysMgt\rac5\racadm.exe' -r $ip -u "root" -p $dracpass --nocertwarn set iDRAC.UserDomain.1.Name corp.pjc.com
}