# A PowerShell script for testing MSSQL connections on remote connections
# Based on https://mcpmag.com/articles/2018/12/10/test-sql-connection-with-powershell.aspx

# Function to configure connection
function Test-SqlConnection {

    ## Configure parameters
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    ## If connection fails
    $ErrorActionPreference = 'Stop'

    ## Try connecting using IP/Database/Username/Password passed to function
    try {
	### Variables to hold the connection values
        $userName = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        ### This will run if the Open() method does not throw an exception
        $true
    } catch {
        $false
    } finally {
        ### Close the connection when we're done
        $sqlConnection.Close()
    }
}

# Help
if ($args[0] -match 'help'){
	Write-Host "Help"
	Write-Host "-----------------------------------------------"
	Write-Host "Test the MSSQL connection on a remote server"
	Write-Host "Usage: .\mssqlTest.ps1 serverIP databaseName"
	Write-Host "-----------------------------------------------"
	Exit
}

# CLI arguments
$serverIP=$args[0]
$dbName=$args[1]

# Checks
## If any of the variables are null, bail.
if(!$serverIP -or !$dbName){
	Write-Host "A variable is undefined"
	Write-Host "-----------------------------------------------"
	Write-Host "Re-run script with valid values"
	Write-Host "Usage: .\mssqlTest.ps1 serverIP databaseName"
	Write-Host "-----------------------------------------------"
	Exit
}

# Run function, fill in ServerName/DatabaseName as required
#Test-SqlConnection -ServerName 'serverIP' -DatabaseName 'DATABASE' -Credential (Get-Credential)

# New run function, pulls in values from CLI
Write-Host "-----------------------------------------------"
Write-Host "Testing connection"
Test-SqlConnection -ServerName $serverIP -DatabaseName $dbName -Credential (Get-Credential)
Write-Host "-----------------------------------------------"
