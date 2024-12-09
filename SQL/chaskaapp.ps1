$serverInstance = "ny5et031\support"
$database = "ServerStorage"
$tableName = "Volume_Datav2"
#$searchString = "esc_sql_ssdf"


$connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

#$query = "SELECT * FROM $tableName WHERE Volume_name LIKE '%$searchString%'"
$query = "SELECT * FROM $tableName"
# Execute the query and store results
$results = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query | ? Total_Space -ne -"0"
$chaskaapp = $results |? volume_name -like "escuaovm001*"


            $groupedData = $chaskaapp | Group-Object Date | ForEach-Object {
                $date = $_.Name
                $totalSpace = ($_.Group | Measure-Object -Property Total_Space -Sum).Sum
                $AvailbleSpace = ($_.Group | Measure-Object -Property Availble_Space -Sum).Sum
                $usedspace = $totalSpace - $AvailbleSpace
                [PSCustomObject]@{
                    Date = $date.Split(' ')[0]
                    Volume_Name = "Chaska_RAC"
                    Total_Space = [math]::Round($totalSpace, 2)
                    Availble_Space = [math]::Round($AvailbleSpace, 2)
                    Used_Space = [math]::Round($usedspace/1024, 2)
                }
            }

            # Display the results
            $eighteenMonthsAgo = (get-date).AddMonths(-18)

            
            $sortedResults = $groupedData | Where-Object {[DateTime]::ParseExact($_.Date, "M/d/yyyy", [System.Globalization.CultureInfo]::InvariantCulture) -ge $eighteenMonthsAgo} | Sort-Object { [DateTime]::ParseExact($_.Date, "M/d/yyyy", [System.Globalization.CultureInfo]::InvariantCulture) }

# Display the results
$sortedResults | Format-Table -AutoSize

