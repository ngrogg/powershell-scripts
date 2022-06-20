# Powershell script to find large files and folders at a provided filepath
# Helper script by Nicholas Grogg

# Help
if ($args[0] -match 'help'){
	Write-Host "Help"
	Write-Host "-----------------------------------------------"
	Write-Host "List the largest files and folders at a given filepath"
	Write-Host "Usage: .\diskSpace.ps1 C:\filepath"
	Write-Host "Run as admin, needs to be able to access directories"
	Write-Host "-----------------------------------------------"
	Exit
}

# Pass filepath variable 
$filepath=$args[0]

# Checks for null variables 
## Check if filepath defined 
if (!$filepath){
	Write-Host "A check has failed"
	Write-Host "-----------------------------------------------"
	$filepath = Read-Host -Prompt "filepath is not defined, please enter a filepath:"
	Write-Host "-----------------------------------------------"
}

# If filepath STILL undefined, exit 
if (!$filepath){
	Write-Host "-----------------------------------------------"
	Write-Host "filepath still undefined, re-run script with a defined filepath"
	Write-Host "Usage: .\diskSpace.ps1 FILEPATH"
	Write-Host "-----------------------------------------------"
	Exit
}

# Formatting
Write-Host "Folders using the most space at $filepath"
Write-Host "-----------------------------------------------"

# Find size of directories at filepath
gci -force $filepath -ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
$len = 0
gci -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
$_.fullname, '{0:N2} GB' -f ($len / 1Gb)
}

# Formatting
Write-Host "-----------------------------------------------"
Write-Host ""

# Formatting 
Write-Host "Files using the most space at $filepath"
Write-Host "-----------------------------------------------"

# Find files in filespath and sort them by size 
gci $filepath -r| sort -descending -property length | select -first 10 name, @{Name="GB";Expression={[Math]::round($_.length / 1GB, 2)}} | Format-Table

# Formatting 
Write-Host "-----------------------------------------------"
