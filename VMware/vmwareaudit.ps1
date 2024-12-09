Connect-VIServer escvc200.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "Lpk>Df(W:?5*" -AllLinked
Connect-VIServer escvc204.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "Lpk>Df(W:?5*"
Connect-VIServer ld4vc001.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "Lpk>Df(W:?5*"
Connect-VIServer escvc203.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "Lpk>Df(W:?5*" -AllLinked

#NTP Info
Get-VMHost | Sort-Object Name | Select-Object Name, @{N=”Cluster”;E={$_ | Get-Cluster}}, 
#@{N=”Datacenter”;E={$_ | Get-Datacenter}}, 
#@{N=“NTPServiceRunning“;E={($_ | Get-VmHostService | Where-Object {$_.key-eq “ntpd“}).Running}}, 
#@{N=“StartupPolicy“;E={($_ | Get-VmHostService | Where-Object {$_.key-eq “ntpd“}).Policy}}, 
#@{N=“NTPServers“;E={$_ | Get-VMHostNtpServer}}, 
#@{N="Date&Time";E={(get-view $_.ExtensionData.configManager.DateTimeSystem).QueryDateTime()}}, 
@{N="Firewall";E={($_ | Get-VMHostFirewallException | Where-Object {$_.Enabled -eq $true}).name}} | format-table -autosize | Export-Csv C:\temp\config.csv



$vmhosts = Get-VMHost

foreach ($vmhost in $vmhosts){
(Get-VMHostFirewallException -VMHost $vmhost | Where-Object {$_.Enabled -eq $true}).name
}

Disconnect-VIServer -Server * -Confirm:$false
