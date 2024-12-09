
# Base Directory
$global:BaseDirectory = "C:\Users\kocah10\haluk-1\"

# JSON configuration filename to use
$global:BaseConfig = ".\send_to_SN_ETS.json"

# Load and parse the JSON configuration file
$global:Config = Get-Content "$BaseDirectory$BaseConfig" -Raw -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue


# Environment (Production, Leaduser, Testing, Development)
$global:environment = ($Config.basic.environment)

#$logLevel = ($Config.Logging.level)
$user = ($Config.Basic.user)
$sn_uri = ($Config.Basic.instance)
$keyfile = $BaseDirectory + ($Config.Basic.keyfile)


# Get password from secure file
$password = Get-Content $keyfile | ConvertTo-SecureString

    $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        
    $credential = New-Object System.Management.Automation.PSCredential($user, $password)


$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}

# Set query parameters to get all active server CIs
$query = "sysparm_limit=10000"
$tableName = "cmdb_ci_server"

# Construct the URI for the WebRequest
$uri = "https://$sn_uri/api/now/table/${tableName}?$query"

# Send WebRequest
$method = "GET"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Method $method -Uri $uri -Credential $credential
$2012count = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Windows 2012 Standard").count
$2016stdcount = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Windows 2016 Standard").count
$2019stdcount = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Windows 2019 Standard").count
$2019dtccount = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Windows 2019 Datacenter").count
$2022stdcount = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Windows 2022 Standard").count
$linuxcount = (($response.Content | ConvertFrom-Json).result | ? subcategory -eq Computer |? install_status -eq 1 | ? virtual -eq "true"| ? os -eq "Linux Red Hat").count



$date = Get-Date -Format "yyyy-MM-dd"


# Define variables
$serverName = "ny5et031\support"
$databaseName = "ServerStorage"
$tableName = "mpr_virtual_os"

# Define the data to insert
$data = @(
    @{OS = "Win 2012"; count = $2012count; date = $date},
    @{OS = "Win 2016"; count = $2016stdcount; date = $date},
    @{OS = "Win 2019"; count = $2019stdcount; date = $date},
    @{OS = "Win 2019 Datacenter"; count = $2019dtccount; date = $date},
    @{OS = "Win 2022"; count = $2022stdcount; date = $date},
    @{OS = "Linux Red Hat"; count = $linuxcount; date = $date};
)

# Establish connection
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

# Create command object
$command = $connection.CreateCommand()

# Insert data
foreach ($row in $data) {
    $columns = $row.Keys -join ','
    $values = "'" + ($row.Values -join "','") + "'"
    $query = "INSERT INTO $tableName ($columns) VALUES ($values)"
    $command.CommandText = $query
    $command.ExecuteNonQuery()
}

# Close connection
$connection.Close()