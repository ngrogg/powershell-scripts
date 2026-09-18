# scripts

Scripts that I've written for PowerShell. <br>

## Scripts
The scripts are as follows: <br>
* **CreateCustomViews.ps1**, PowerShell script to create custom views to view Error/Critical Errors on Windows Events.
  Also creates a view for power off/on cycles. <br>
  Also creates a view for password changes. <br>
  Script is idempotent so it can safely be run repeatedly. <br>
  Usage, just run the script as Administrator. <br>
* **DiskSpace.ps1**, A PowerShell script to find the largest files and folders at a provided filepath.
  Takes a filepath as an argument, doesn't have to be C:\ drive. For best results run in admin powerShell prompt. <br>
  Usage, `.\diskSpace.ps1 C:\FILEPATH` <br>
* **EventViewerRetention.ps1**, A PowerShell script to extend the retention size for Event Viewer. <br>
  Sets the `Application` retention to 256 MB. <br>
  Sets the `System` retention to 256 MB. <br>
  Sets the `Security` retention to 1024 MB. <br>
  Script is idempotent so it can safely be run repeatedly. <br>
  Script will not set values if current value is larger than target value. <br>
  Usage, just run the script as Administrator. <br>
* **FakeTop.ps1**, A PowerShell script designed to emulate top output. Lists the processes using the most CPU.
  Usage, just run the script. Control + C to exit. <br>
  See comments for rundown of output and sources. <br>
* **HelloWorld.ps1**, the simple 'hello world' script to test that everything is configured and working on your system. <br>
  Usage, just run the script <br>
* **LocalUserAudit**, A PowerShell script for checking when the last time a local user logged on and if their password is expired. <br>
  Must be run with Admin permissions. <br>
  Arguments: <br>
  - **help**, Output help function and exit
  - **audit**, check server for the last time local users logged in and if their passwords are expired.
  Usage, `.\localUserAudit.ps1 audit`.
* **MssqlTest.ps1**, A PowerShell script to test MSSQL connections.
  Takes a server IP and database name as an argument. <br>
  Usage, `.\mssqlTest.ps1 IP databaseName` <br>
* **UserCreation.ps1**, A PowerShell script to create a user. Guided, designed for use with Password Manager Pro.
  Takes a username, first name, last name and user type as an argument. <br>
  Usage, `.\userCreation.ps1 userType userName firstName lastName` <br>
  Ex. `.\userCreation.ps1 admin jdoe John Doe` <br>
* **UserGroups.ps1**, A PowerShell script to list the groups a local user is in.
  Takes an action and user name as an argument. <br>
  Arguments: <br>
  * **help**, output help message and exit.
  * **groups**, when a username is passed will list all groups user is in.
    Usage, `.\userGroups.ps1 groups USERNAME` <br>
    Ex. `.\userGroups.ps1 groups jdoe` <br>
* **UserRemoval.ps1**, A PowerShell script for locking or removing Local Users from a Windows Server.
  If locking a user account, removes them from admin group if they're in admin group.
  Removing a user does exactly that, removes them from the server.
  Takes action and username as an argument. Has a help function, needs run as administrator. <br>
  Usage, `.\userRemoval.ps1 ACTION USERNAME` <br>
  Ex. `.\userRemoval.ps1 remove jdoe` <br>
  Ex. `.\userRemoval.ps1 lock jdoe` <br>
