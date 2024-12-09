$hostname = 


$vmhost = get-vmhost $hostname

$ntpservers = $vmhost | get-VMHostNtpServer

foreach ($ntpserver in $ntpservers){
$vmhost | Remove-VMHostNtpServer $ntpserver
}

#NTP Configuration
$vmhost | Add-VMHostNtpServer -NtpServer time001.corp.pjc.com
$vmhost | Add-VMHostNtpServer -NtpServer time002.corp.pjc.com
$vmhost | Add-VMHostNtpServer -NtpServer time003.corp.pjc.com
$vmhost | Add-VMHostNtpServer -NtpServer time004.corp.pjc.com

