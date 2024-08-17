# userGroups.ps1
# PowerShell script to list groups user is a member of
# By Nicholas Grogg

# Help
function helpFunction {
	Write-Host "Help"
	Write-Host "-------------------------------------------"
	Write-Host "List groups Local User is a member of"
	Write-Host ""
	Write-Host "help/Help"
	Write-Host "* Output this help message and exit"
	Write-Host ""
	Write-Host "Groups"
	Write-Host "* List groups local user is a member of"
	Write-Host "* Takes username as argument"
	Write-Host "Usage: .\userGroups.ps1 Groups username"
	Write-Host "Ex. .\userGroups.ps1 Groups ngrogg"
}

# User Creation Function
function mainFunction($username){
	Write-Host "Listing user groups for $username"
	Write-Host "-------------------------------------------"

	## Get list of groups
	$userGroups = Get-LocalGroup

	## Iterate through groups and output each group username is found in
	Write-Host "User '$username' is in the following local groups: "
	foreach ($group in $userGroups) {
		if (Get-LocalGroupMember -Name $group | Select-String "$username") {
			Write-Host "- $($group.Name)"
		}
	}
}

# Main, parse passed flags
Write-Host "User Groups"
Write-Host "-------------------------------------------"
Write-Host "Checking flags passed"
Write-Host "-------------------------------------------"

# Check passed values, run functions based on input
switch ($args[0]) {
	"Help" {
		Write-Host "Help Function"
		Write-Host "-------------------------------------------"
		helpFunction
		Exit
	}
	"Groups" {
		Write-Host "List User Groups"
		Write-Host "-------------------------------------------"
		mainFunction $args[1]
		Exit
	}
	default {
		Write-Host "ISSUE - Invalid input detected!"
		Write-Host "-------------------------------------------"
		Write-Host "Running Help function and exiting"
		helpFunction
		Exit
	}
}
