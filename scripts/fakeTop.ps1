# FakeTop
# PowerShell script to imitate top w/ output
# Lists processes using the most CPU
# By Nicholas Grogg

# Based on this
# https://www.sqlserver-dba.com/2016/03/powershell-script-powershell-equivalent-of-linux-top.html

# Help
if ($args[0] -match 'help'){
	Write-Host "Help"
	Write-Host "-----------------------------------------------"
	Write-Host "PowerShell script to output processes using the most CPU"
	Write-Host "Output is similar to top, hence the name"
	Write-Host "No argument, just run the script"
	Write-Host ""
	Write-Host "How to read output:"
    Write-Host "NPM(K): The amount of non-paged memory that the process is using, in kilobytes."
    Write-Host "PM(K): The amount of pageable memory that the process is using, in kilobytes."
    Write-Host "WS(K): The size of the working set of the process, in kilobytes."
    Write-Host "The working set consists of the pages of memory that were recently referenced by the process."
	Write-Host ""
    Write-Host "VM(M): The amount of virtual memory that the process is using, in megabytes."
    Write-Host "Virtual memory includes storage in the paging files on disk."
	Write-Host ""
    Write-Host "CPU(s): The amount of processor time that the process has used on all processors, in seconds."
    Write-Host "ID: The process ID (PID) of the process."
    Write-Host "ProcessName: The name of the process."
    Write-Host ""
    Write-Host "Cancel script w/ Control + C!"
    Write-Host ""
	Write-Host "help/Help"
	Write-Host "* Output this help message and exit"
	Write-Host "-----------------------------------------------"
	Exit
}

# Source for Help,
# https://superuser.com/questions/169386/what-do-the-headers-in-the-powershell-ps-output-mean

while (1) {ps | sort -desc cpu | select -first 30; sleep -seconds 2; cls;
Write-Host "Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName";
Write-Host "-------  ------    -----      ----- -----   ------     -- -----------"}
