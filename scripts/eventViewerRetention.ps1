#Requires -RunAsAdministrator

# eventViewerRetention.ps1
# Configures Event Log retention sizes for Application, System, and Security logs.
# By Nicholas Grogg
# Revision: 20260909

<#
.SYNOPSIS
    Configures Event Log retention sizes for Application, System, and Security logs.
.DESCRIPTION
    Sets log sizes with circular logging (OverwriteAsNeeded). If an existing log size
    is already equal to or greater than the target size, the larger size is retained.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

# Key-value mapping of log names and target sizes in Megabytes (MB).
$logSettings = @(
    @{ Name = "Application"; SizeMB = 256 },
    @{ Name = "System";      SizeMB = 256 },
    @{ Name = "Security";    SizeMB = 1024 }
)

$blockSizeBytes = 64KB

Write-Verbose "Starting Event Log Configuration..."

foreach ($setting in $logSettings) {
    $logName = $setting.Name
    $targetSizeBytes = [int64]$setting.SizeMB * 1MB

    # Ensure size is aligned to the required 64KB boundary
    $remainder = $targetSizeBytes % $blockSizeBytes
    if ($remainder -ne 0) {
        $targetSizeBytes += ($blockSizeBytes - $remainder)
    }

    $targetSizeMB = [math]::Round($targetSizeBytes / 1MB)

    # Detect active Group Policy overrides
    $gpoPath = "HKLM:\Software\Policies\Microsoft\Windows\EventLog\$logName"
    if (Test-Path $gpoPath) {
        Write-Warning "Log '$logName' has Group Policy settings at '$gpoPath'. Manual changes may be reverted by GPO."
    }

    # Load log configuration using modern Eventing API (compatible with PS 5.1 and PS 7+)
    try {
        $logConfig = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::new($logName)
    }
    catch {
        Write-Warning "Log '$logName' does not exist or is inaccessible on this machine. Skipping."
        continue
    }

    $currentSizeBytes = $logConfig.MaximumSizeInBytes
    $currentSizeMB = [math]::Round($currentSizeBytes / 1MB)
    $isCircular = $logConfig.LogMode -eq [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular
    $isSizeSufficient = $currentSizeBytes -ge $targetSizeBytes

    if ($isSizeSufficient -and $isCircular) {
        Write-Host "[SKIP] '$logName' size ($currentSizeMB MB) is >= target ($targetSizeMB MB) and Circular mode is active." -ForegroundColor Green
        continue
    }

    $newSize = if ($isSizeSufficient) { $currentSizeBytes } else { $targetSizeBytes }
    $actionMessage = "Set maximum size to $([math]::Round($newSize / 1MB)) MB and mode to Circular"

    if ($PSCmdlet.ShouldProcess("EventLog: $logName", $actionMessage)) {
        try {
            $logConfig.MaximumSizeInBytes = $newSize
            $logConfig.LogMode = [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular
            $logConfig.SaveChanges()
            Write-Host "[SUCCESS] '$logName' updated successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update log '$logName': $_"
        }
    }
}
