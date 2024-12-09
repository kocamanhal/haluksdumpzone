
$ip = "10.50.50.93"
$PSDefaultParameterValues['Invoke-WebRequest:UseBasicParsing'] = $true
add-type @"
using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
WebRequest request, int certificateProblem) {
return true;
    }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy



function Invoke-SqlQuery {
    param(
        [string]$Query
    )

    Write-Output $Query
    $Server = "ny5et031\support"
    $Database = "ServerStorage"
    $ConnectionString = "Server=$Server;Database=$Database;Integrated Security=True;"
    $Results = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query 

 
    return $Results
}

$queryip = "SELECT COUNT(*) FROM vcenterfirewall WHERE ip = '$ip'"

$resultsip = Invoke-SqlQuery -Query $queryip

$rules =ForEach ($resultallip in $resultallips) {
    if ($resultallip.ip -ne $null){
        @{
            "address" = $resultallip.ip
            "prefix" = $resultallip.prefix  # Assuming each IP is a single host
            "interface_name" = "nic0"
            "policy" = "ACCEPT"
        }
    }
}

$rules += @{
    "address" = "0.0.0.0"
    "prefix" = "0"
    "interface_name" = "nic0"
    "policy" = "REJECT"
}

# Create the final structure
$fw_conf_json = @{
    rules = $rules
} | ConvertTo-Json -Depth 3


$vcServer = 'testvc1.corp.pjc.com'
$username = "administrator@vsphere.local"
$password = "Kirep1054!"   

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}
$sessionUrl = "https://$vcServer/rest/com/vmware/cis/session"

    $response = Invoke-RestMethod -Uri $sessionUrl -Method Post -Headers $headers
    $sessionId = $response.value

$headers = @{
    "vmware-api-session-id" = ($sessionId | ConvertFrom-Json).Value
    "Content-Type" = "application/json"
}

# Apply the new firewall rules
$response = Invoke-WebRequest -Method PUT -Uri "https://$vcServer/api/appliance/networking/firewall/inbound" -Headers $headers -Body $fw_conf_json
