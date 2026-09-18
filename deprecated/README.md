# Scrapped

## Overview
Scripts that I've retired, deprecated or superceded with other scripts.

## Scripts
* **LastLogin.ps1**, A PowerShell script for listing the last login of non-Default users. <br>
  Usage, `.\lastLogin.ps1 login` <br>
  Also has a help function <br>
  Usage, `.\lastLogin.ps1 help` <br>
* **userLock**, A PowerShell script to disable and lock a Local User. Takes a username as argument.
  Superceded by the `userRemoval` script. <br>
  Find list of users with `Get-LocalUser`. <br>
  Usage, `.\userLock.ps1 username` <br>
  Ex. `.\userLock.ps1 jdoe` <br>
