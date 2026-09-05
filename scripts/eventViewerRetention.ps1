#Requires -RunAsAdministrator

# eventViewerRetention.ps1
# Configures Event Log retention sizes for Application, System, and Security logs.
# By Nicholas Grogg
# Revision: 20260905

<#
.SYNOPSIS
    Configures Event Log retention sizes for Application, System, and Security logs.
.DESCRIPTION
    This script sets log sizes (Application: 256MB, System: 256MB, Security: 1024MB)
    with circular logging (OverwriteAsNeeded). If an existing log size is already equal
    to or greater than the target size, the larger size is retained.
#>

# 1. Enforce Administrator Privileges Check
# Ensures execution halts cleanly with a message if run in a non-elevated session.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "Access Denied: This script requires Administrator privileges. Please re-run PowerShell as Administrator."
    exit 1
}

# 2. Define Desired Log Configurations
# Key-value mapping of log names and target sizes in Megabytes (MB).
$logSettings = @(
    @{ Name = "Application"; SizeMB = 256 },
    @{ Name = "System";      SizeMB = 256 },
    @{ Name = "Security";    SizeMB = 1024 }
)

Write-Host "--- Starting Event Log Configuration ---" -ForegroundColor Cyan

# 3. Iterate through each log and apply settings if necessary
foreach ($setting in $logSettings) {
    $logName = $setting.Name
    $targetSizeMB = $setting.SizeMB

    # Convert target size MB to KB and Bytes
    $targetSizeKB = $targetSizeMB * 1024
    $targetSizeBytes = $targetSizeMB * 1MB

    # Fetch current event log properties for comparison
    $currentLog = Get-EventLog -List | Where-Object { $_.Log -eq $logName }

    if ($null -eq $currentLog) {
        Write-Warning "Log '$logName' does not exist on this machine. Skipping."
        continue
    }

    $currentSizeKB = $currentLog.MaximumKilobytes
    $currentSizeMB = [math]::Round($currentSizeKB / 1024)
    $overflowMatches = $currentLog.OverflowAction -eq "OverwriteAsNeeded"
    $isSizeSufficient = $currentSizeKB -ge $targetSizeKB

    # IDEMPOTENCY & THRESHOLD CHECK:
    # - If current size >= target size and overflow matches: Skip
    # - If current size >= target size but overflow differs: Update OverflowAction only (preserve larger size)
    # - If current size < target size: Update size to target and set OverflowAction
    if ($isSizeSufficient -and $overflowMatches) {
        Write-Host "[SKIP] '$logName' current size ($currentSizeMB MB) is >= target ($targetSizeMB MB) and OverwriteAsNeeded is set." -ForegroundColor Green
    }
    elseif ($isSizeSufficient -and -not $overflowMatches) {
        Write-Host "[UPDATE] '$logName' current size ($currentSizeMB MB) is >= target ($targetSizeMB MB). Updating OverflowAction to OverwriteAsNeeded..." -ForegroundColor Yellow
        try {
            Limit-EventLog -LogName $logName -OverflowAction OverwriteAsNeeded -ErrorAction Stop
            Write-Host "[SUCCESS] '$logName' overflow action updated successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update overflow action for '$logName': $_"
        }
    }
    else {
        Write-Host "[UPDATE] Increasing '$logName' size from $currentSizeMB MB to ${targetSizeMB} MB..." -ForegroundColor Yellow
        try {
            Limit-EventLog -LogName $logName -MaximumSize $targetSizeBytes -OverflowAction OverwriteAsNeeded -ErrorAction Stop
            Write-Host "[SUCCESS] '$logName' updated successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update '$logName': $_"
        }
    }
}

Write-Host "--- Configuration Complete ---" -ForegroundColor Cyan
