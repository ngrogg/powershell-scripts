# Powershell script to create new users on Windows Server
# Creates new users, optionally adds them to Admin group and restarts PMP
# Can also set user passwords and add/remove users from groups
# Helper script by Nicholas Grogg

# Help
function helpFunction {
	Write-Host "Help"
	Write-Host "-------------------------------------------"
	Write-Host "Creates a user for Windows Server"
	Write-Host "Run as admin, needs to restart PMP service"
	Write-Host ""
	Write-Host "help/Help"
	Write-Host "* Output this help message and exit"
	Write-Host ""
	Write-Host "setPass"
	Write-Host "* Set user password, used for nfs/samba"
	Write-Host "Usage: .\userCreation.ps1 setPass username"
	Write-Host ""
	Write-Host "groupMod"
	Write-Host "* Modify user group"
	Write-Host "* Takes username, action and group as arguments"
	Write-Host "Usage: .\userCreation.ps1 groupMod username action group"
	Write-Host "Ex. .\userCreation.ps1 groupMod jdoe add Administrators"
	Write-Host "Ex. .\userCreation.ps1 groupMod jdoe remove Administrators"
	Write-Host ""
	Write-Host "admin/Admin"
	Write-Host "* Create local admin user"
	Write-Host "Usage: .\userCreation.ps1 admin username firstName lastName"
	Write-Host "Ex. .\userCreation.ps1 admin jdoe John Doe"
	Write-Host ""
	Write-Host "regular/Regular"
	Write-Host "* Create regular local user"
	Write-Host "Usage: .\userCreation.ps1 regular username firstName lastName"
	Write-Host "Ex. .\userCreation.ps1 regular jdoe John Doe"
}

# Password set function
function setPassFunction($username){
	Write-Host "Set Password"
	Write-Host "-------------------------------------------"
	Write-Host "Enter password to set for user $username"

	# Read in password as secure string
	$Password    = Read-Host -AsSecureString

	# Define user account based on passed values
	$UserAccount = Get-LocalUser -Name "$username"

	# Set account password
	$UserAccount | Set-LocalUser -Password $Password
}

# User group modifier function
function groupMod($username,$useraction,$groupName){
	Write-Host "Group Modification"
	Write-Host "-------------------------------------------"

	## Is username null?
	if (!$username){
		Write-Host "A check has failed"
		Write-Host "-----------------------------------------------"
		$username = Read-Host -Prompt "username not defined, please enter a username of format initial/last name ex. jdoe: "
		Write-Host "-----------------------------------------------"
	}

	## Does user exist?
	Write-Host "Checking if user $username exists"
	Write-Host "-----------------------------------------------"
	$checkUserExists = Get-LocalUser | where-Object Name -eq "$username" | Measure

	## If user exists, proceed
	if ($checkUserExists.Count -eq 1) {
		Write-Host "User $username exists"
		Write-Host "-----------------------------------------------"
		Write-Host "Proceeding!"
	}
	## Else exit
	else {
		Write-Host "User $username doesn't exist!"
		Write-Host "-----------------------------------------------"
		Write-Host "Exiting"
		Exit
	}

	## If useraction = add, add user to group
	if ($useraction -eq 'add'){
		Write-Host "Adding user $username to $groupName"
		Write-Host "-----------------------------------------------"

		### Add user to group
		Add-LocalGroupMember -Group $groupName -Member $username
	}
	## Else If useraction = remove, remove user from group
	elseif ($useraction -eq 'remove'){
		Write-Host "Removing user $username from $groupName"
		Write-Host "-----------------------------------------------"

		### Remove user from group
		Remove-LocalGroupMember -Group $groupName -Member $username

	}
	## Else something is wrong, exit with error
	else {
		Write-Host "ISSUE DETECTED - EXITING"
		Write-Host "-----------------------------------------------"
		Write-Host "Invalid user action requested"
		Write-Host "Running help function and exiting"
		helpFunction
		Exit
	}

	### Output current group members
	Write-Host "Current members of group $groupName"
	Write-Host "-----------------------------------------------"
	Get-LocalGroupMember -Name $groupName
}

# User Creation Function
function userFunction($userType,$username,$firstName,$lastName){
	Write-Host "User creation"
	Write-Host "-------------------------------------------"

	## Create a full name from passed names
	$fullName = "$firstName $lastName"

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

	## Create user
	### Set password, doesn't actually matter since PMP will be used to set the user password before sharing user
	$password="VerySecurePass1!"

	### Convert string to secure string
	$encryptedPassword=ConvertTo-SecureString -String $password -AsPlainText -Force

	### Create user
	New-LocalUser $username -Password $encryptedPassword -FullName $fullName

	### Add user to admin group if applicable
	if ($userType -eq 'admin') {
		Write-Host "-----------------------------------------------"
		Write-Host "User $username created as Admin"
		#### Add user to Admin group
		Add-LocalGroupMember -Group Administrators -Member $username
	}
	else {
		Write-Host "-----------------------------------------------"
		Write-Host "User $username created as non-Admin"

		#### Add user to Remote Desktop Users group
		Add-LocalGroupMember -Group "Remote Desktop Users" -Member $username
	}

	## Restart pmp
	Restart-Service -Name PMP_Agent
}
# Main, parse passed flags
Write-Host "User Creation"
Write-Host "-------------------------------------------"
Write-Host "Checking Flags passed"
Write-Host "-------------------------------------------"

# Check passed values, run functions based on input
switch ($args[0]) {
	"Help" {
		Write-Host "Help Function"
		Write-Host "-------------------------------------------"
		helpFunction
		Exit
	}
	"setPass" {
		Write-Host "Set User password"
		Write-Host "-------------------------------------------"
		setPassFunction $args[1]
		Exit
	}
	"groupMod"{
		Write-Host "Modifying user group"
		Write-Host "-------------------------------------------"
		groupMod $args[1] $args[2] $args[3]
	}
	"Admin" {
		Write-Host "Create Admin user"
		Write-Host "-------------------------------------------"
		userFunction $args[0] $args[1] $args[2] $args[3]
		Exit
	}
	"Regular" {
		Write-Host "Create non-Admin user"
		Write-Host "-------------------------------------------"
		userFunction $args[0] $args[1] $args[2] $args[3]
		Exit
	}
	default {
		Write-Host "Invalid Input detected, outputting Help"
		Write-Host "-------------------------------------------"
		helpFunction
		Exit
	}
}
