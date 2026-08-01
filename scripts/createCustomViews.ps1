#Requires -RunAsAdministrator

# Create Custom Views
# PowerShell script to create custom views on a Windows Server

$ErrorActionPreference = 'Stop'

# Define target folder.
$viewsDirectory = "$env:ProgramData\Microsoft\Event Viewer\Views\Server Errors"

# Ensure the target directory exists
try {
    if (-not (Test-Path -Path $viewsDirectory)) {
        New-Item -Path $viewsDirectory -ItemType Directory -Force | Out-Null
    }
}
catch {
    Write-Error "Failed to create directory $viewsDirectory. $_"
    return
}

# List of custom views to create
$customViews = @(
    @{ Name = "Application Errors";       Log = "Application" },
    @{ Name = "Security Errors";          Log = "Security" },
    @{ Name = "Setup Errors";             Log = "Setup" },
    @{ Name = "System Errors";            Log = "System" },
    @{ Name = "Forwarded Events Errors"; Log = "ForwardedEvents" }
)

foreach ($view in $customViews) {
    # Generate Event Viewer XML configuration
    $xmlContent = @"
<ViewerConfig>
<QueryConfig>
<QueryParams>
  <UserQuery />
</QueryParams>
<QueryNode>
  <Name>$($view.Name)</Name>
  <Description>Shows Critical (Level 1) and Error (Level 2) events for the $($view.Log) log.</Description>
  <QueryList>
    <Query Id="0" Path="$($view.Log)">
      <Select Path="$($view.Log)">*[System[(Level=1 or Level=2)]]</Select>
    </Query>
  </QueryList>
</QueryNode>
</QueryConfig>
</ViewerConfig>
"@

    # Define XML output file path
    $fileName = "$($view.Name).xml"
    $filePath = Join-Path -Path $viewsDirectory -ChildPath $fileName

    # Write the custom view file
    try {
        Set-Content -Path $filePath -Value $xmlContent -Encoding UTF8 -Force
        Write-Host "Created Custom View: '$($view.Name)' -> $filePath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create custom view '$($view.Name)'. $_"
    }
}

# Define target folder for Power Events.
$powerEventsDirectory = "$env:ProgramData\Microsoft\Event Viewer\Views\Power Events"

# Ensure the target directory exists
try {
    if (-not (Test-Path -Path $powerEventsDirectory)) {
        New-Item -Path $powerEventsDirectory -ItemType Directory -Force | Out-Null
    }
}
catch {
    Write-Error "Failed to create directory $powerEventsDirectory. $_"
    return
}

# Generate Event Viewer XML configuration for Power Events
$powerEventsXmlContent = @"
<ViewerConfig>
<QueryConfig>
<QueryParams>
  <UserQuery />
</QueryParams>
<QueryNode>
  <Name>Power Events</Name>
  <Description>Tracks all reboots and power on/off events.</Description>
  <QueryList>
    <Query Id="0" Path="System">
      <Select Path="System">*[System[(EventID=41 or EventID=1074 or EventID=1076 or EventID=6005 or EventID=6006 or EventID=6008)]]</Select>
    </Query>
  </QueryList>
</QueryNode>
</QueryConfig>
</ViewerConfig>
"@

# Define XML output file path
$powerEventsFileName = "Power Events.xml"
$powerEventsFilePath = Join-Path -Path $powerEventsDirectory -ChildPath $powerEventsFileName

# Write the custom view file
try {
    Set-Content -Path $powerEventsFilePath -Value $powerEventsXmlContent -Encoding UTF8 -Force
    Write-Host "Created Custom View: 'Power Events' -> $powerEventsFilePath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create custom view 'Power Events'. $_"
}

Write-Host "Close and re-open Event Viewer if needed"
