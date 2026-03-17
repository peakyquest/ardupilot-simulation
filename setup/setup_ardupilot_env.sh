#!/usr/bin/env bash

# Exit on error, undefined variable, or failed pipe
set -e

echo "========================================="
echo " ArduPilot Build Environment Setup Script"
echo "========================================="
echo

# Function to print step headers
step() {
    echo
    echo "-----------------------------------------"
    echo ">> $1"
    echo "-----------------------------------------"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Please do NOT run this script as root."
   echo "Run it as a normal user (it will use sudo when needed)."
   exit 1
fi

# Update system
step "Updating package list"
sudo apt-get update -y

# Install git if not present
step "Installing Git"
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
else
    echo "Git already installed"
fi

# Move to Home directory
step "Moving to Home directory"
cd "$HOME"

# Clone ArduPilot repo
step "Cloning ArduPilot repository"
if [ -d "ardupilot" ]; then
    echo "ArduPilot already exists, pulling latest changes"
    cd ardupilot
    git pull
else
    git clone https://github.com/ArduPilot/ardupilot.git
    cd ardupilot
fi

# Run prerequisite installer
step "Installing ArduPilot prerequisites"
chmod +x Tools/environment_install/install-prereqs-ubuntu.sh
Tools/environment_install/install-prereqs-ubuntu.sh -y

# Setup environment variables
step "Setting up environment variables"

if ! grep -q "ardupilot/Tools/autotest" ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/ardupilot/Tools/autotest' >> ~/.bashrc
    echo "Added autotest to PATH"
else
    echo "autotest PATH already set"
fi

if ! grep -q "/usr/lib/ccache" ~/.bashrc; then
    echo 'export PATH=/usr/lib/ccache:$PATH' >> ~/.bashrc
    echo "Added ccache to PATH"
else
    echo "ccache PATH already set"
fi

# Reload bashrc
step "Reloading bash configuration"
source ~/.bashrc

echo
echo "========================================="
echo "ArduPilot setup completed successfully!"
echo "========================================="
