$eventId = 7036
$description = "The Powershell Universal service entered the stopped state."

# Get the event log
$events = Get-WinEvent -FilterHashtable @{LogName='System'; Id=$eventId} | Where-Object { $_.Message -like "*$description*" }

# Display the matching events
$events | Format-Table TimeCreated, Id, Message