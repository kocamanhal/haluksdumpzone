# Import the SQL Server module
Import-Module SqlServer

# CSV and SQL Server connection details
$csvPath = "C:\temp\mprphysicalos.csv"
$serverInstance = "ny5et031\support"
$database = "ServerStorage"
$table = "Volume_Datav2"

# Read the CSV file
$csvData = Import-Csv -Path $csvPath

# Prepare the SQL connection
$connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

# Prepare the SQL command
$command = $connection.CreateCommand()
$command.CommandText = "INSERT INTO $table (OS, Count, Date) VALUES (@OS, @Count, @Date)"

# Parameters for the SQL command
$locationParam = $command.Parameters.Add("@OS", [System.Data.SqlDbType]::NVarChar, 255)
$countParam = $command.Parameters.Add("@Count", [System.Data.SqlDbType]::Int)
$dateParam = $command.Parameters.Add("@Date", [System.Data.SqlDbType]::Date)

# Loop through each row in the CSV and insert into SQL
foreach ($row in $csvData) {
    $locationParam.Value = $row.OS
    $countParam.Value = [int]$row.Count
    $dateParam.Value = [DateTime]::ParseExact($row.Date, "yyyy-MM-dd", $null)
    
    $command.ExecuteNonQuery()
}

# Close the connection
$connection.Close()

Write-Host "Data import completed successfully."