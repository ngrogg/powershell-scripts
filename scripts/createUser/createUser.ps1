# Powershell script to create new users on Windows Server 
# Creates new user
# Helper script by Nicholas Grogg

# Help
if ($args[0] -match 'help'){
	Write-Host "Help"
	Write-Host "-----------------------------------------------"
	Write-Host "Creates a user for Windows Server"
	Write-Host "Usage: .\userCreation.ps1 username FirstName LastName"
	Write-Host "Ex. .\userCreation.ps1 jdoe John Doe"
	Write-Host "Run as admin, needs to be able to restart PMP service"
	Write-Host "-----------------------------------------------"
	Exit
}

# Pass variables to script 
$username=$args[0]
$firstName=$args[1]
$lastName=$args[2]
$fullName="$firstName $lastName"

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

# Create user 
## Set a temp password, make sure to have user change this!
$password="VerySecurePass1!"

## Convert string to secure string
$encryptedPassword=ConvertTo-SecureString -String $password -AsPlainText -Force

## Create user 
New-LocalUser $username -Password $encryptedPassword -FullName $fullName

# TODO Set up creation of non-admin user
# Set user as admin
Add-LocalGroupMember -Group Administrators -Member $username
