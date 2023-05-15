# scripts

Scripts that I've written for PowerShell. <br>

## Scripts
The scripts are as follows: <br>
* **helloWorld**, the simple 'hello world' script to test that everything is configured and working on your system. <br>
  Usage, just run the script <br>
* **diskSpace**, A PowerShell script to find the largest files and folders at a provided filepath.
  Takes a filepath as an argument, doesn't have to be C:\ drive. For best results run in admin powerShell prompt. <br>
  Usage, `.\diskSpace.ps1 C:\FILEPATH` <br>
* **mssqlTest**, A PowerShell script to test MSSQL connections.
  Takes a server IP and database name as an argument. <br>
  Usage, `.\mssqlTest.ps1 IP databaseName` <br>
* **userCreation**, A PowerShell script to create a user. Guided, designed for use with Password Manager Pro.
  Takes a username, first name, last name and user type as an argument. <br>
  Usage, `.\userCreation.ps1 userType userName firstName lastName` <br>
  Ex. `.\userCreation.ps1 admin jdoe John Doe` <br>
* **userRemoval.ps1**, A PowerShell script for locking or removing Local Users from a Windows Server.
  If locking a user account, removes them from admin group if they're in admin group.
  Removing a user does exactly that, removes them from the server.
  Takes action and username as an argument. Has a help function, needs run as administrator. <br>
  Usage, `.\userRemoval.ps1 ACTION USERNAME` <br>
  Ex. `.\userRemoval.ps1 remove jdoe` <br>
  Ex. `.\userRemoval.ps1 lock jdoe` <br>
