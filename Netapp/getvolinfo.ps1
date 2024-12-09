$user = "corp\svcs_monitoring"
$pass = ConvertTo-SecureString -String "~NWd1sc0v3ry!" -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass



Connect-NcController -Name ny5stg01 -Credential $Credentials

Connect-NcController -Name escstg01 -Credential $Credentials

Get-NcVol | select * | Export-Csv C:\temp\vols.csv

Get-NcVserver | select * | Export-Csv C:\temp\svms.csv

$stgs = "escstg01", "ny5stg01"

$col = @()


foreach ($stg in $stgs){

Connect-NcController -Name $stg -Credential $Credentials

$vols = Get-NcVol

foreach ($vol in $vols){
$svm = get-ncvserver $vol.vserver
$mm = "" | select system, Aggregate, vserver, vserver_state, Protocols, svmdr, vol_name, vol_state, isprotected, SnapshotPolicy, svmstate, AntiRansomware, ObjectStore
$mm.vol_name = $vol.Name
$mm.vol_state = $vol.State
$mm.isprotected = $vol.SnapMirror.IsProtected
$mm.SnapshotPolicy = $vol.VolumeSnapshotAttributes.SnapshotPolicy
$mm.vserver = $vol.Vserver
$mm.vserver_state = $svm.State
$mm.svmstate = $svm.State
$mm.svmdr = $svm.IsVserverProtected
$mm.system = $stg
$mm.Aggregate = $vol.Aggregate
$mm.AntiRansomware = $vol.AntiRansomware.State
$mm.ObjectStore = $vol.IsObjectStore
$mm.Protocols = $svm.AllowedProtocols | out-string
$col += $mm
}
}

$col | export-csv c:\temp\volprotect.csv



Get-NcVol | Where {$_.AntiRansomware.State -eq "dry_run"}


(Get-NcSnapshot -ZapiCall | ? name -like "*anti*" | Measure-Object -Property Total -sum).count