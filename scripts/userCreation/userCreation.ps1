# Powershell script to create new users on Windows Server 
# Creates new user
# Helper script by Nicholas Grogg

# Help
if ($args[0] -match 'help'){
	Write-Host "Help"
	Write-Host "-----------------------------------------------"
	Write-Host "Creates a user for Windows Server"
	Write-Host "Usage: .\userCreation.ps1 username FirstName LastName adminbool"
	Write-Host "Ex. .\userCreation.ps1 jdoe John Doe admin"
	Write-Host "Admin bool on end will create user as admin, leave blank for normal user"
	Write-Host "-----------------------------------------------"
	Exit
}

# Pass variables to script 
$username  = $args[0]
$firstName = $args[1]
$lastName  = $args[2]
$adminBool = $args[3]
$fullName  = "$firstName $lastName"

# Some basic checks for null variables 
## Is username null?
if (!$username){
	Write-Host "A check has failed"
	Write-Host "-----------------------------------------------"
	$username = Read-Host -Prompt "username not defined, please enter a username of format initial/last name ex. jdoe: "
	Write-Host "-----------------------------------------------"
}

## Is firstName null? 
if (!$firstName){
	Write-Host "A check has failed"
	Write-Host "-----------------------------------------------"
	$firstName = Read-Host -Prompt "First name not defined, please enter a first name ex. John: "
	Write-Host "-----------------------------------------------"
}

## Is lastName null?
if (!$lastName){
	Write-Host "A check has failed"
	Write-Host "-----------------------------------------------"
	$lastName = Read-Host -Prompt "Last name not defined, please enter a last name ex. Doe: "
	Write-Host "-----------------------------------------------"
}

## Check if admin null
if (!$adminBool){
	Write-Host "IMPORTANT, created user will not be an Admin!"
	Write-Host "-----------------------------------------------"
	$confirm   = Read-Host -Prompt "Created user will not be an admin, enter 'y' to continue or 'n' to exit: "
	Write-Host "-----------------------------------------------"
	if ($confirm -eq "y"){
		Write-Host "Creating non-admin user $fullName"
	}
	elseif ($confirm -eq "n"){
		Write-Host "Exiting!"
		exit
	}
	else {
		Write-Host "Invalid input detected, re-run script with valid input"
		exit
	}
}

## If any of the variables are STILL null, bail. 
if(!$username -or !$firstName -or !$lastName){
	Write-Host "A variable is still undefined"
	Write-Host "-----------------------------------------------"
	Write-Host "Re-run script with valid values"
	Write-Host "Usage: .\userCreation.ps1 username FirstName LastName"
	Write-Host "-----------------------------------------------"
	Exit
}

## Else everything clear, make the user!
else {
	Write-Host "-----------------------------------------------"
	Write-Host "All checks clear, creating user"
	Write-Host "-----------------------------------------------"
}

exit

# Create user 
## Set a temp password, make sure to have user change this!
$password="VerySecurePass1!"

## Convert string to secure string
$encryptedPassword=ConvertTo-SecureString -String $password -AsPlainText -Force

## Create user 
New-LocalUser $username -Password $encryptedPassword -FullName $fullName

# Set user as admin
## Check if admin bool null
if ($adminBool){
	Add-LocalGroupMember -Group Administrators -Member $username
}
