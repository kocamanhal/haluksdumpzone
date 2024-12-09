################## Make sure one VM owns all the disks in cluster management ##################
################## When vmotining make sure disk format is THICK PROVISION EAGER ZERO ##############
########## Max number of VMs in single WSFC cluster is 5
############ Max num of WSFC clusters running on the same set of ESXi hosts 3
######### Max number of clusted VMDKs per esxi host 128
##### Set QuorumArbitrationTimeMax to 60
######## Physical disk must support ATS SCSI commands



#######Getting RDM information##############

$vms = "escstet006e", "escstet006f", "escstet006g", "escstet006h"
$vms = "NY5ET062a"

foreach ($vm in $vms){
$vm = Get-VM $vm

$rdmInfo = Get-HardDisk -VM $vm | Where-Object {$_.DiskType -eq 'RawPhysical' -or $_.DiskType -eq 'RawVirtual'} | 
ForEach-Object {
    $controller = $_.Parent.ExtensionData.Config.Hardware.Device | 
                  Where-Object {$_ -is [VMware.Vim.VirtualSCSIController] -and $_.DeviceInfo.Label -eq $_.ControllerKey}
    
    $unitNumber = $_.ExtensionData.UnitNumber
    $controllerKey = $_.ExtensionData.ControllerKey
    $lun = 
    New-Object PSObject -Property @{
        Vmname = $vm
        Name = $_.Name
        DeviceName = $_.DeviceName
        ScsiCanonicalName = $_.ScsiCanonicalName
        Filename = $_.Filename
        CapacityKB = $_.CapacityKB
        DiskType = $_.DiskType
        ScsiController = $controller.DeviceInfo.Label
        ScsiPosition = "$($controller.BusNumber):$unitNumber"
        LunNumber = (Get-ScsiLun -VmHost $vm.VMHost -CanonicalName $_.ScsiCanonicalName).RuntimeName.Split("L")[-1]
    }
}

$rdmInfo | Format-Table -AutoSize
}

Get-ScsiLun -VmHost $vm.VMHost -CanonicalName $rdminfo[0].ScsiCanonicalName 
##############removing the RDMs from server

$vmName = "escstet006f"
$vm = Get-VM $vmName

# Get all RDM disks attached to the VM
$rdmDisks = Get-HardDisk -VM $vm | Where-Object {$_.DiskType -eq 'RawPhysical' -or $_.DiskType -eq 'RawVirtual'}

foreach ($disk in $rdmDisks) {
    # Get disk information before removal
    $diskInfo = [PSCustomObject]@{
        Name = $disk.Name
        DeviceName = $disk.DeviceName
        ScsiCanonicalName = $disk.ScsiCanonicalName
        Filename = $disk.Filename
        CapacityKB = $disk.CapacityKB
        DiskType = $disk.DiskType
        ScsiController = $disk.ExtensionData.ControllerKey
        UnitNumber = $disk.ExtensionData.UnitNumber
    }
    Remove-HardDisk -HardDisk $disk -Confirm:$false -DeletePermanently:$false
    Write-Output "Removed RDM disk from VM $vmName :"
    $diskInfo | Format-Table -AutoSize
}

############## Storage vMotion the RDMs to shared VMFS

$vm = Get-VM CSKDVET006f

$rdmInfo = Get-HardDisk -VM $vm | Where-Object {$_.ExtensionData.ControllerKey -eq "1001"} | 
ForEach-Object {
    $controller = $_.Parent.ExtensionData.Config.Hardware.Device | 
                  Where-Object {$_ -is [VMware.Vim.VirtualSCSIController] -and $_.DeviceInfo.Label -eq $_.ControllerKey}
    
    $unitNumber = $_.ExtensionData.UnitNumber
    $controllerKey = $_.ExtensionData.ControllerKey
    
    New-Object PSObject -Property @{
        Vmname = $vm
        Name = $_.Name
        DeviceName = $_.DeviceName
        ScsiCanonicalName = $_.ScsiCanonicalName
        Filename = $_.Filename
        CapacityKB = $_.CapacityKB
        DiskType = $_.DiskType
        ScsiController = $controller.DeviceInfo.Label
        ScsiPosition = "$($controller.BusNumber):$unitNumber"
    }
}

$rdmInfo | Format-Table -AutoSize


################Add disk to VM

$rdmInfo = Get-HardDisk -VM $vm | Where-Object {$_.ExtensionData.ControllerKey -eq "1001"} | Select-Object -ExpandProperty Filename

foreach ($rdm in $rdminfo){
$vm = Get-VM "CSKDVET006j"

$vm | New-HardDisk -DiskPath $rdm `
-Controller "SCSI controller 1" `
-OutVariable hd

$diskDevice = $hd.ExtensionData
$diskDeviceBaking = $hd.ExtensionData.backing

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec
$spec.deviceChange[0].operation = 'edit'
$spec.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$spec.deviceChange[0].device = $diskDevice
$spec.DeviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$spec.DeviceChange[0].device.backing = $diskDeviceBaking
$spec.DeviceChange[0].device.Backing.Sharing = "sharingMultiWriter"


Write-Host "`nEnabling Multiwriter flag on on VMDK:" $hd.Name "for VM:" $vm.name
$task = $vm.ExtensionData.ReconfigVM_Task($spec)
$task1 = Get-Task -Id ("Task-$($task.value)")
$task1 | Wait-Task

}




##########################

# Get the VM (replace "YourVMName" with the actual VM name)
$vm = Get-VM "CSKDVET006j"

# Get all hard disks attached to SCSI controller 1
$disks = Get-HardDisk -VM $vm | Where-Object { $_.ExtensionData.ControllerKey -eq 1001 }

# Change the disk mode to independent persistent for each disk
foreach ($disk in $disks) {
    Set-HardDisk -HardDisk $disk -Persistence IndependentPersistent -Confirm:$false
}

# Verify the changes
Get-HardDisk -VM $vm | Where-Object { $_.ExtensionData.ControllerKey -eq 1000 } | Select-Object Name, CapacityGB, Persistence