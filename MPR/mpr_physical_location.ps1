$username = 'admin'
$pass = ConvertTo-SecureString -String 'Ngw58@Kc' -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass
Connect-OMEServer -Name csklx007.corp.pjc.com -Credentials $credentials

#Physical devices by location from OME
$ny5physical = (get-OMEDevice | ? NetworkAddress -like "10.50.*").count
$cskphysical = (get-OMEDevice | ? {($_.NetworkAddress -like "10.20.*") -or ($_.NetworkAddress -like "10.128.*")}).count 
$abdphyical = (get-OMEDevice | ? NetworkAddress -like "10.92.*").count
$ld4physical = (get-OMEDevice | ? NetworkAddress -like "10.90.*").count
$mspphysical = (get-OMEDevice | ? NetworkAddress -like "10.10.*").count
$branch = (Get-OMEDevice).count - $ny5physical - $cskphysical - $abdphyical - $ld4physical - $mspphysical



$date = Get-Date -Format "yyyy-MM-dd"


# Define variables
$serverName = "ny5et031\support"
$databaseName = "ServerStorage"
$tableName = "mpr_physical_locations"

# Define the data to insert
$data = @(
    @{location = "Aberdeen"; count = $abdphyical; date = $date},
    @{location = "LD4"; count = $ld4physical; date = $date},
    @{location = "Chaska"; count = $cskphysical; date = $date},
    @{location = "NY5"; count = $ny5physical; date = $date},
    @{location = "MSP"; count = $mspphysical; date = $date},
    @{location = "Branch"; count = $branch; date = $date};
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