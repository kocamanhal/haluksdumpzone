$serverInstance = "ny5et031\support"
$database = "ServerStorage"
$tableName = "vcenterfirewall"
$vcServer = 'ny5vc002.corp.pjc.com'
$username = "administrator@vsphere.local"
$password = 'V$ph3r3@dmin'



$connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

#$query = "SELECT * FROM $tableName WHERE Volume_name LIKE '%$searchString%'"
$query = "SELECT * FROM $tableName"

$results = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query 


$rules =ForEach ($resultallip in $results) {
        @{
            "address" = $resultallip.ip
            "prefix" = $resultallip.prefix  # Assuming each IP is a single host
            "interface_name" = "nic0"
            "policy" = "ACCEPT"
        }
    
}

$rules += @{
    "address" = "0.0.0.0"
    "prefix" = "0"
    "interface_name" = "nic0"
    "policy" = "REJECT"
}

$fw_conf_json = @{
    rules = $rules
} | ConvertTo-Json -Depth 3

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}
$sessionUrl = "https://$vcServer/rest/com/vmware/cis/session"

    $response = Invoke-RestMethod -Uri $sessionUrl -Method Post -Headers $headers -SkipCertificateCheck
    $sessionId = $response.value

$headers = @{
    "vmware-api-session-id" = $sessionId 
    "Content-Type" = "application/json"
}

# Apply the new firewall rules
$response = Invoke-WebRequest -Method PUT -Uri "https://$vcServer/api/appliance/networking/firewall/inbound" -Headers $headers -Body $fw_conf_json -SkipCertificateCheck
