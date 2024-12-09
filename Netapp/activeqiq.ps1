$baseUrl = "https://esclx025/api"
$username = "CA_SSM_Storage4"
$password = '.B7bBa@hFo!F'

# Create authentication header
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

# Authenticate and get access token
$authUrl = "$baseUrl/auth/login"
$response = Invoke-RestMethod -Uri $authUrl -Headers $headers -Method Post

# Extract the token from the response
$token = $response.token


$headers["Authorization"] = "Bearer $token"

# Get volume information
$volumesUrl = "$baseUrl/storage-provider/volumes"
$volumes = Invoke-RestMethod -Uri $volumesUrl -Headers $headers -Method Get

# Process and display the results
$volumes.records | ForEach-Object {
    [PSCustomObject]@{
        VolumeName = $_.name
        TotalSpace = [math]::Round($_.space.size / 1GB, 2)
        UsedSpace = [math]::Round($_.space.used / 1GB, 2)
        AvailableSpace = [math]::Round($_.space.available / 1GB, 2)
        PercentAvailable = [math]::Round(($_.space.available / $_.space.size) * 100, 2)
    }
} | Format-Table -AutoSize