#!/usr/bin/bash

# BASH script to install and enable snaps, as well as to install powershell
# Tested on Debian Sid 

# First update system
sudo apt update -y && sudo apt upgrade -y

# Install snapd and core
sudo apt install snapd 
sudo snap install core 

# Enable snapd service 
sudo systemctl start snapd 
sudo systemctl enable snapd

# Install powershell
sudo snap install powershell --classic 

# Create symlink between snap executable and pwsh
sudo ln -s /snap/bin/pwsh /usr/bin/pwsh
