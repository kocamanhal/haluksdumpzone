# Find VMs with USB Controller enabled
$vms = Get-View -ViewType VirtualMachine -Property Name,Config.Hardware.Device

$usbEnabledVMs = @()
foreach ($vm in $vms) {
    try {
        $devices = $vm.Config.Hardware.Device | Where-Object { $_.GetType().Name -eq "VirtualUSBController" }
        if ($devices) {
            $usbEnabledVMs += New-Object PSObject -Property @{
                VM = $vm.Name
                Controller = $devices.DeviceInfo.Label
            }
        }
    } catch {
        continue
    }
}

# Display VMs with USB Controller enabled
$usbEnabledVMs

$clustersToExclude = @("Minneapolis", "Atlanta_FSG", "Memphis_FSG")

$vms = get-datacenter branch | get-cluster | Where-Object { $_.Name -notin $clustersToExclude } | get-vm | ? PowerState -eq "PoweredOn"

foreach ($vm in $vms){

$vm | Get-VMStartPolicy |? StartAction -eq "None"
$vm | Get-VMStartPolicy |? StartAction -eq "Manual"

}