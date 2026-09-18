# userRemoval
# PowerShell script to lock or remove a Windows user
# By Nicholas Grogg

# Help
function helpFunction {
	Write-Host "Help"
	Write-Host "-------------------------------------------"
	Write-Host "userRemoval"
	Write-Host ""
	Write-Host "help/Help"
	Write-Host "* Output this help message and exit"
	Write-Host ""
	Write-Host "lock/Lock"
	Write-Host "* Lock user"
	Write-Host "* Takes a username as an argument"
	Write-Host "Ex. .\userRemoval.ps1 lock jdoe"
	Write-Host ""
	Write-Host "remove/Remove"
	Write-Host "* Remove user"
	Write-Host "* Takes a username as an argument"
	Write-Host "Ex. .\userRemoval.ps1 remove jdoe"
}

# Main Function
function mainFunction(){
	## Assign passed values to variables
	$action   = $args[0]
	$username = $args[1]

	## Check user is to be removed
	Write-Host "Confirmation - Username"
	Write-Host "-----------------------------------------------"
	$inputVar = Read-Host -Prompt "Confirm username $username (yes/no) "

	## Check input
	switch ($inputVar) {
		"Yes" {
			Write-Host "Confirmed!"
			Write-Host "-------------------------------------------"
			Write-Host "Proceeding!"
		}
		"No" {
			Write-Host "No changes will be made"
			Write-Host "-------------------------------------------"
			Write-Host "Exiting"
			Exit
		}
		default {
			Write-Host "Invalid Input detected"
			Write-Host "-------------------------------------------"
			Write-Host "Exiting"
			Exit
		}
	}

	## Check if user exists
	Write-Host "Check if user $username exists"
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

	## Alter user based on passed action
	switch ($action) {
		"Lock" {
			Write-Host "Locking User $username"
			Write-Host "-------------------------------------------"

			### Lock user
			Disable-LocalUser -Name $username
		}
		"Remove" {
			Write-Host "Removing User $username"
			Write-Host "-------------------------------------------"

			### Remove user
			Remove-LocalUser -Name $username

			### Remove user files
			#### Filepath variable
			$filepath="C:\Users\$username"

			#### Remove files
			Remove-Item -force $filepath -recurse -ErrorAction SilentlyContinue

		}
		default {
			Write-Host "Invalid Input detected"
			Write-Host "-------------------------------------------"
			Write-Host "Running help function and exiting"
			helpFunction
			Exit
		}
	}

}

# Main, parse passed flags
Write-Host "User Removal"
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
	"Remove" {
		Write-Host "User Removal"
		Write-Host "-------------------------------------------"
		mainFunction $args[0] $args[1]
	}
	"Lock" {
		Write-Host "User Locking"
		Write-Host "-------------------------------------------"
		mainFunction $args[0] $args[1]
	}
	default {
		Write-Host "Invalid Input detected"
		Write-Host "-------------------------------------------"
		Write-Host "Running help function and exiting"
		helpFunction
		Exit
	}
}
