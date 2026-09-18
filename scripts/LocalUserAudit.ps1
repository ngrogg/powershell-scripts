#Requires -RunAsAdministrator

# Local User Audit
# Reviews all Local Users on a Windows Server and outputs the last time
# each user logged in and if their password is expired.
# By Nicholas Grogg
# Revision: 1.0

<#
.SYNOPSIS
    Audits all local user accounts on a Windows Server.
.DESCRIPTION
    Reviews all local users on a Windows Server and outputs the account name,
    enabled status, last logon time, password expiration status, and password
    expiration date.
    This script is read-only and does not modify any user accounts or settings.
#>

# Help
function helpFunction {
    Write-Host "Help"
    Write-Host "-------------------------------------------"
    Write-Host "Local User Audit"
    Write-Host "Reviews all Local Users on a Windows Server and outputs:"
    Write-Host " - Last logon timestamp"
    Write-Host " - Password expiration status"
    Write-Host ""
    Write-Host "Help"
    Write-Host "* Output this help message and exit"
    Write-Host "Audit"
    Write-Host "* Run the local user audit process"
}

# Main Function
function mainFunction {
    Write-Host "Audit"
    Write-Host "-------------------------------------------"

    # 1. Enforce Administrator Privileges Check
    # Ensures execution halts cleanly with a message if run in a non-elevated session.
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Error "Access Denied: This script requires Administrator privileges. Please re-run PowerShell as Administrator."
        exit 1
    }

    # 2. Check if host is a Domain Controller
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($null -ne $os -and $os.ProductType -eq 2) {
            Write-Warning "This machine is an Active Directory Domain Controller. Local SAM accounts do not exist on Domain Controllers; user accounts are managed in Active Directory."
            return
        }
    }
    catch {
        # Continue if CIM query is unavailable
    }

    Write-Host "--- Starting Local User Audit ---" -ForegroundColor Cyan

    $auditResults = @()

    # 3. Query Local Users using Get-LocalUser (PowerShell 5.1+ / LocalAccounts module)
    if (Get-Command -Name Get-LocalUser -ErrorAction SilentlyContinue) {
        try {
            $localUsers = Get-LocalUser -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve local user accounts: $_"
            return
        }

        foreach ($user in $localUsers) {
            $isPasswordExpired = $false

            # Check if password expiration timestamp is set and has passed
            if ($null -ne $user.PasswordExpires) {
                if ((Get-Date) -gt $user.PasswordExpires) {
                    $isPasswordExpired = $true
                }
            }

            # Check ADSI WinNT user object to identify accounts where 'User must change password at next logon' is set
            try {
                $adsiUser = [ADSI]"WinNT://$env:COMPUTERNAME/$($user.Name),user"
                if ($adsiUser.PasswordExpired -eq 1 -or $adsiUser.PasswordExpired -eq -1) {
                    $isPasswordExpired = $true
                }
            }
            catch {
                # If ADSI query fails, retain the date-based calculation
            }

            # Format LastLogon timestamp
            $lastLogonDisplay = if ($null -ne $user.LastLogon) {
                $user.LastLogon.ToString("yyyy-MM-dd HH:mm:ss")
            }
            else {
                "Never"
            }

            # Format PasswordExpires timestamp
            $passwordExpiresDisplay = if ($null -ne $user.PasswordExpires) {
                $user.PasswordExpires.ToString("yyyy-MM-dd HH:mm:ss")
            }
            else {
                "Never"
            }

            # Format PasswordLastSet timestamp
            $passwordLastSetDisplay = if ($null -ne $user.PasswordLastSet) {
                $user.PasswordLastSet.ToString("yyyy-MM-dd HH:mm:ss")
            }
            else {
                "Never"
            }

            $auditResults += [PSCustomObject]@{
                UserName        = $user.Name
                Enabled         = $user.Enabled
                LastLogon       = $lastLogonDisplay
                PasswordExpired = $isPasswordExpired
                PasswordExpires = $passwordExpiresDisplay
                PasswordLastSet = $passwordLastSetDisplay
            }
        }
    }
    else {
        # Fallback for legacy environments lacking Microsoft.PowerShell.LocalAccounts
        Write-Warning "Get-LocalUser cmdlet not found. Falling back to ADSI WinNT provider..."
        try {
            $adsiComputer = [ADSI]"WinNT://$env:COMPUTERNAME"
            $adsiUsers = $adsiComputer.Children | Where-Object { $_.SchemaClassName -eq "User" }
        }
        catch {
            Write-Error "Failed to retrieve local user accounts via ADSI: $_"
            return
        }

        foreach ($u in $adsiUsers) {
            $userName = $u.Name.Value
            $userFlags = $u.UserFlags.Value
            $enabled = (-not ($userFlags -band 2))

            $lastLogin = try { $u.LastLogin.Value } catch { $null }
            $lastLogonDisplay = if ($null -ne $lastLogin) {
                ([datetime]$lastLogin).ToString("yyyy-MM-dd HH:mm:ss")
            }
            else {
                "Never"
            }

            $isPasswordExpired = try {
                ($u.PasswordExpired.Value -eq 1) -or ($u.PasswordExpired.Value -eq -1)
            }
            catch {
                $false
            }

            $auditResults += [PSCustomObject]@{
                UserName        = $userName
                Enabled         = $enabled
                LastLogon       = $lastLogonDisplay
                PasswordExpired = $isPasswordExpired
                PasswordExpires = "N/A"
                PasswordLastSet = "N/A"
            }
        }
    }

    # 4. Output Results Table
    if ($auditResults.Count -gt 0) {
        Write-Host ""
        $auditResults | Format-Table -AutoSize
        Write-Host ""

        # Summary statistics
        $totalCount         = $auditResults.Count
        $enabledCount       = ($auditResults | Where-Object { $_.Enabled -eq $true }).Count
        $disabledCount      = ($auditResults | Where-Object { $_.Enabled -eq $false }).Count
        $expiredCount       = ($auditResults | Where-Object { $_.PasswordExpired -eq $true }).Count
        $neverLoggedInCount = ($auditResults | Where-Object { $_.LastLogon -eq "Never" }).Count

        Write-Host "--- Audit Summary ---" -ForegroundColor Cyan
        Write-Host "Total Accounts Audited : $totalCount"
        Write-Host "Enabled Accounts       : $enabledCount"
        Write-Host "Disabled Accounts      : $disabledCount"
        Write-Host "Password Expired       : $expiredCount"
        Write-Host "Never Logged In        : $neverLoggedInCount"
        Write-Host "---------------------" -ForegroundColor Cyan
    }
    else {
        Write-Host "No local user accounts were found." -ForegroundColor Yellow
    }

    Write-Host "--- Audit Complete ---" -ForegroundColor Cyan
}

# Main, parse passed flags
Write-Host "Local User Audit"
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
    "Audit" {
        Write-Host "Audit"
        Write-Host "-------------------------------------------"
        mainFunction
        Exit
    }
    $null {
        Write-Host "Audit (Default)"
        Write-Host "-------------------------------------------"
        mainFunction
        Exit
    }
    "" {
        Write-Host "Audit (Default)"
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
