$user = "corp\svcs_monitoring"
$pass = ConvertTo-SecureString -String "~NWd1sc0v3ry!" -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass



Connect-NcController -Name escstg01, ny5stg01 -Add -Credential $Credentials

$vols = Get-NcVol
$nodes = get-ncnode
$aggr = Get-NcAggr

Connect-VIServer escvc200.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password 'Jq+O[aNmO=7C' -AllLinked

Connect-VIServer -AllLinked

$vms = Get-VM 

$info = @()

foreach ($vm in $vms){

$vm | Get-HardDisk | ? DiskType -ne "RawPhysical" | ForEach-Object {
    $disk = $_
    $datastore = $disk | Get-Datastore
    
    $myObj = "" | Select-Object VMName, Cluster, CapacityGB, format, DatastoreName, Datastoreused,  Aggregate, usednetapp, Model
    $myObj.VMName = $vm.Name
    $myObj.CapacityGB = $disk.CapacityGB
    $myObj.format = $disk.StorageFormat
    $myObj.DatastoreName = $datastore.Name
    $myObj.Datastoreused = [math]::round((($datastore.CapacityGB) - ($datastore.FreeSpaceGB))/1024, 2)
    $myObj. Cluster = (get-cluster -vm $vm).name
    $volname = $datastore.Name+"_vol"
    $myObj.usednetapp = [math]::round(((($vols | ? name -eq $volname).TotalSize)-(($vols |? name -eq $volname).Available))/1TB, 2)
    $myObj.Aggregate = ($vols | ? name -eq $volname).Aggregate
    $myObj.Model = $nodes | ? Node -eq (($aggr | ? name -eq (($vols | ? name -eq $volname).Aggregate)).HomeNode.name) | select -ExpandProperty nodemodel
    $info += $myObj
    }
}



get-ncvol | ? Aggregate -Like (Get-NcAggr | ? HomeNode -like $selectnode).name


 $nodes | ? Node -eq (($aggr | ? name -eq $vol.Aggregate).HomeNode.name) | select -ExpandProperty nodemodel