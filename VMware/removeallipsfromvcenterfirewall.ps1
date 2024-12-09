$vcServer = 'testvc1.corp.pjc.com'
$username = "administrator@vsphere.local"
$password = "Kirep1054!"   


$rules =
        @{
            "address" = "0.0.0.0"
            "prefix" = "0"  # Assuming each IP is a single host
            "interface_name" = "nic0"
            "policy" = "ACCEPT"
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
        
            $response = Invoke-RestMethod -Uri $sessionUrl -Method Post -Headers $headers
            $sessionId = $response.value
        
        $headers = @{
            "vmware-api-session-id" = ($sessionId | ConvertFrom-Json).Value
            "Content-Type" = "application/json"
        }
        
        # Apply the new firewall rules
        $response = Invoke-WebRequest -Method PUT -Uri "https://$vcServer/api/appliance/networking/firewall/inbound" -Headers $headers -Body $fw_conf_json
        