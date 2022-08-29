#!/usr/bin/bash

# Install script for RHEL 7
# Change curl URL for required version (8 for 8 etc.)

# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo yum install --assumeyes powershell

# Start PowerShell
pwsh
