$username = "corp\svcs_monitoring"
$pass = ConvertTo-SecureString -String '~NWd1sc0v3ry!' -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass

#Aberdeen
Connect-VIServer ld4vc001.corp.pjc.com -Credential $credentials
$abdvms = (get-datacenter 'Aberdeen' | get-vm | ? PowerState -eq "PoweredOn").count

#LD4
$ld4vms = (Get-Datacenter 'London LD4' | Get-VM | ? PowerState -eq "PoweredOn").count
Disconnect-VIServer * -confirm:$false

#Chaska
$cskolvmUrls = "https://escualx013.corp.pjc.com/ovirt-engine/api/", "https://escualx014.corp.pjc.com/ovirt-engine/api/", "https://esclx200.corp.pjc.com/ovirt-engine/api/", "https://esclx200.corp.pjc.com/ovirt-engine/api/", "https://esclx202.corp.pjc.com/ovirt-engine/api/"
$ny5olvmUrls = "https://ny5drlx007.corp.pjc.com/ovirt-engine/api/", "https://ny5drlx008.corp.pjc.com/ovirt-engine/api/"
$username = "admin@internal"  # Replace with your username
$password = "fR00tUnIX"     # Replace with your password

# Create a base64-encoded authorization string
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${username}:${password}")))

$cskvmCount = @()

foreach ($olvmUrl in $cskolvmUrls){
# Get VM information
$response = Invoke-RestMethod -Uri "$olvmUrl/vms" -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UseBasicP -SkipCertificateCheck

# Count VMs
$cskvmCount += ($response.vms.vm | ? status -eq "up").Count

}

#+2 is for OVM VMs that don't have api
$cskolvm = ($cskvmcount | Measure-Object -Sum).Sum + 2

Connect-VIServer escvc200.corp.pjc.com -Credential $credentials -AllLinked
$cskvmwarevms = (Get-Datacenter 'Eagan Production Environment' | Get-VM | ? PowerState -eq "PoweredOn").count
$chaskavms = $cskolvm + $cskvmwarevms

#NY5
$ny5vmCount = @()

foreach ($olvmUrl in $ny5olvmUrls){
# Get VM information
$response = Invoke-RestMethod -Uri "$olvmUrl/vms" -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UseBasicP -SkipCertificateCheck

# Count VMs
$ny5vmCount += ($response.vms.vm | ? status -eq "up").Count

}

#+2 is for OVM VMs that don't have api
$ny5olvm = ($ny5vmcount | Measure-Object -Sum).Sum

$ny5vmwarevms = (Get-Datacenter 'NewYork Production Environment' | Get-VM | ? PowerState -eq "PoweredOn").count
$ny5vms = $ny5olvm + $ny5vmwarevms

Disconnect-VIServer * -confirm:$false

#Branches
Connect-VIServer escvc204.corp.pjc.com -Credential $credentials
$branchvms = (get-cluster | ? {($_.Name -ne "Minneapolis")-and ($_.Name -ne "uat")} | get-vm | ? PowerState -eq "PoweredOn").count

#MSP
$mspvms = (get-cluster "minneapolis" | get-vm | ? PowerState -eq "PoweredOn").count

#UAT
$uatvms = (get-cluster "uat" | get-vm | ? PowerState -eq "PoweredOn").count


