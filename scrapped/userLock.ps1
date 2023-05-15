# Powershell script to lock users on Windows Server
# Helper script by Nicholas Grogg

# help
if ($args[0] -match "help"){
	write-host "Help"
	write-host "-----------------------------------------------"
	write-host "Locks a user for windows server"
	write-host "usage: .\userLock.ps1 username"
	write-host "ex. .\userLock.ps1 jdoe"
	write-host "-----------------------------------------------"
	Exit
}

# Pass username to script
$username=$args[0]

# Checks
# Is username null?
if (!$username){
	Write-Host "ISSUE DETECTED"
	Write-Host "-----------------------------------------------"
	$username = Read-Host -Prompt "username not defined, please enter a username of format initial/last name ex. jdoe: "
	Write-Host "-----------------------------------------------"
}

## Is username STILL null?
if (!$username){
	Write-Host "ISSUE DETECTED"
	Write-Host "-----------------------------------------------"
	Write-Host "Username still null, exiting!"
	Exit
}

## Check user is to be removed
Write-Host "Confirmation - Username"
Write-Host "-----------------------------------------------"
$inputVar = Read-Host -Prompt "Confirm if user is to be disabled (yes/no): "
Write-Host "-----------------------------------------------"

# If input = "yes" or "Yes", lock user account
if ($inputVar -eq "yes" -or $inputVar -eq "Yes" -or $inputVar -eq "y" -or $inputVar -eq "Y"){
## Lock user account
Write-Host "Locking user account"
Write-Host "-----------------------------------------------"
Disable-LocalUser -Name $username

## Output user status to confirm user disabled
Write-Host "Confirming user locked"
Write-Host "-----------------------------------------------"
Get-LocalUser -Name $username
}

# If input = "no" or "No", quit
elseif($inputVar -eq "no" -or $inputVar -eq "No"){
	Write-Host "Not locking user"
	Write-Host "-----------------------------------------------"
	Write-Host "Exiting"
	Exit
}

# Else Exit with error message
else{
	Write-Host "ISSUE DETECTED"
	Write-Host "-----------------------------------------------"
	Write-Host "Invalid input detected, re-run script"
	Exit
}
