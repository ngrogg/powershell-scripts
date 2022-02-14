#!/usr/bin/bash

# Script to install powershell on Debian based systems
# Currently set for Debian 11

# Download deb file 
wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt update -y && sudo apt upgrade -y

# Install PowerShell
sudo apt install -y powershell
