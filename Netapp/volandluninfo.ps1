$luns = Get-NcLun
$vols  =Get-NcVol
$info = @()


foreach ($lun in $luns){
$lun |  ForEach-Object {
    

    $myObj = "" | Select-Object Lunname, LunSizeused, LunSizeAssigned, Volname, Volsizeused, VolSizeAssigned

    $myObj.Lunname = $lun.LogicalUnit
    $myObj.LunSizeused = [math]::round($lun.SizeUsed / 1gb)
    $myObj.LunSizeAssigned = [math]::round($lun.size / 1gb)
    $myObj.Volname = $lun.volume
    $myObj.Volsizeused = [math]::round((($vols | ? name -eq $lun.volume | select -ExpandProperty TotalSize) / 1gb) - (($vols | ? name -eq $lun.volume | select -ExpandProperty Available) / 1gb))
    $myObj. VolSizeAssigned = [math]::round(($vols | ? name -eq $lun.volume | select -ExpandProperty TotalSize) / 1gb)
    $info += $myObj
    }
}

$info = @()

foreach ($vol in $vols){

 $myObj = "" | Select-Object volname, size, used, maxgrow, reserve,vserver

$myObj.volname = $vol.Name
$myObj.size = ($vol).TotalSize /1tb
$myObj.used = ($vol).Used /1tb
$myObj.maxgrow = ($vol | Get-NcVolAutosize | select -ExpandProperty MaximumSize) /1tb
$myObj.reserve = ($vol | get-NcVolOption | ? name -eq fractional_reserve).value
$myObj.vserver = $vol.vserver
$info += $myObj
}

$info | Export-Csv C:\temp\frac1.csv

Get-NcVol -Name escovm012_13_lun28_vol | Set-NcVolAutosize -Enabled $false




volume modify -vserver escstg01fc -volume escovm012_13_lun28_vol -autosize-mode off


escovm012_13_lun28_vol

Get-NcVol -Name ny5drovm003_4_lun20_vol | Get-NcVolAutosize | fl