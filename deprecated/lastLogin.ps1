# Last Login
# List the last login of all non-Default users on the server
# By Nicholas Grogg

# Help
function helpFunction {
	Write-Host "Help"
	Write-Host "-------------------------------------------"
	Write-Host "Last Login"
	Write-Host "List last login of all non-Default users"
	Write-Host ""
	Write-Host "help/Help"
	Write-Host "* Output this help message and exit"
	Write-Host ""
	Write-Host "login/Login"
	Write-Host "* List last logins"
}

# Main Function
function mainFunction(){
	Write-Host "Running Program"
	Write-Host "-------------------------------------------"

    ## Parse out the default accounts, store result in an array. Add other users if needed
    $userArray=Get-LocalUser | Select-String -Pattern "Administrator|DefaultAccount|Guest|WDAGUtilityAccount" -NotMatch

    ## Iterate through list, output items
    foreach ($i in $userArray) {
            Write-Host $i;
            Get-LocalUser $i | Format-List -Property LastLogon
    }
}

# Main, parse passed flags
Write-Host "Last Login"
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
	"Login" {
		Write-Host "Last Login"
		Write-Host "-------------------------------------------"
		mainFunction
		Exit
	}
	default {
		Write-Host "Invalid Input detected, exiting"
		Write-Host "-------------------------------------------"
		Exit
	}
}
