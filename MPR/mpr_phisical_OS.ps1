$username = 'admin'
$pass = ConvertTo-SecureString -String 'Ngw58@Kc' -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass
Connect-OMEServer -Name csklx007.corp.pjc.com -Credentials $credentials

$esxi = (get-OMEDevice | Where-Object {( $_.DeviceName -like "*vs*") -or ( $_.DnsName -like "*vs*")}).count + 6
$olvm  = (get-OMEDevice |  Where-Object {( $_.DeviceName -like "*ovm*") -or ( $_.DnsName -like "*ovm*")}).count - 4
$windows = (get-OMEDevice |  Where-Object {( $_.DeviceName -notlike "*ovm*") -and ( $_.DnsName -notlike "*ovm*") -and ( $_.DeviceName -notlike "*vs*") -and ( $_.DnsName -notlike "*vs*")}).count

$date = Get-Date -Format "yyyy-MM-dd"


# Define variables
$serverName = "ny5et031\support"
$databaseName = "ServerStorage"
$tableName = "mpr_physical_os"

# Define the data to insert
$data = @(
    @{OS = "ESXi"; count = $esxi; date = $date},
    @{OS = "OLVM"; count = $olvm; date = $date},
    @{OS = "OVM"; count = "4"; date = $date},
    @{OS = "Windows"; count = $windows; date = $date};
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