$vms = get-vmhost ny5vs001v.corp.pjc.com | Get-VM

foreach ($vm in $vms){
$vm | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq "VLAN230_VDI_Citrix"} | Set-NetworkAdapter -NetworkName "VLAN230_VDI_Citrixs" -Confirm:$false
}



Disconnect-VIServer -Server * -Confirm:$false
