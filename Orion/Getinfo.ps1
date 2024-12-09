
ping 
$user = "corp\CA_SSM_Windows5"
$pass = ConvertTo-SecureString -String "K5uE7KJ6D[f$" -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass

$Server01 = New-PSSession -ComputerName escap433 -Credential $credentials




$swis = Connect-Swis -Hostname escap321.corp.pjc.com -UserName 'Vmauto' -Password 'Jrf03(254&%ik8ubn'

$vm = Get-vm ny5lx047
$vmname = $vm.name

get-swisdata $swis "SELECT Caption FROM Orion.Nodes Where Caption like '%$vmname%'"
