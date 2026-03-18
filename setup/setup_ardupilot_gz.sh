#!/usr/bin/env bash

# Exit on error
set -e

echo "========================================="
echo " ArduPilot Gazebo (Harmonic) Setup Script"
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

###############################################################################
# 1. Install dependencies for Gazebo Harmonic
###############################################################################
step "Installing Gazebo Harmonic dependencies"
sudo apt-get update -y
sudo apt-get install -y libgz-sim8-dev rapidjson-dev
sudo apt-get install -y \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl

###############################################################################
# 2. Clone and build ardupilot_gazebo in $HOME
###############################################################################
step "Cloning and building ardupilot_gazebo"
ARDUPILOT_GZ_DIR="$HOME/ardupilot_gazebo"

if [[ -d "$ARDUPILOT_GZ_DIR/.git" ]]; then
    echo "ardupilot_gazebo already exists at $ARDUPILOT_GZ_DIR, pulling latest changes"
    cd "$ARDUPILOT_GZ_DIR"
    git pull
else
    echo "Cloning ardupilot_gazebo into $ARDUPILOT_GZ_DIR"
    git clone https://github.com/ArduPilot/ardupilot_gazebo "$ARDUPILOT_GZ_DIR"
    cd "$ARDUPILOT_GZ_DIR"
fi

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j"$(nproc)"

###############################################################################
# 3. Append Gazebo environment variables to ~/.bashrc
###############################################################################
step "Configuring Gazebo environment variables"

BASHRC="$HOME/.bashrc"
PLUGIN_LINE='export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}'
RESOURCE_LINE='export GZ_SIM_RESOURCE_PATH=$HOME/ardupilot_gazebo/models:$HOME/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}'

add_line_if_missing() {
    local line="$1"
    local file="$2"
    if ! grep -Fxq "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        echo "Added: $line"
    else
        echo "Already present: $line"
    fi
}

add_line_if_missing "$PLUGIN_LINE" "$BASHRC"
add_line_if_missing "$RESOURCE_LINE" "$BASHRC"

###############################################################################
# 4. Reload bashrc
###############################################################################
step "Reloading bash configuration"
source "$BASHRC"

echo
echo "========================================="
echo "ArduPilot Gazebo setup completed successfully!"
echo "Repository: $ARDUPILOT_GZ_DIR"
echo "Open a new terminal or start using Gazebo with ArduPilot."
echo "========================================="

#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# ArduPilot Gazebo (Harmonic) setup script
# - Installs Gazebo Harmonic dependencies
# - Clones and builds ArduPilot/ardupilot_gazebo into $HOME/ardupilot_gazebo
# - Appends required Gazebo environment variables to ~/.bashrc
###############################################################################

echo "=== ArduPilot Gazebo (Harmonic) setup ==="

if [[ $EUID -ne 0 ]]; then
  echo "This script will call sudo when needed."
fi

###############################################################################
# 1. Install dependencies for Gazebo Harmonic
###############################################################################
echo "=== Installing Gazebo Harmonic dependencies ==="
sudo apt update
sudo apt install -y libgz-sim8-dev rapidjson-dev
sudo apt install -y \
  libopencv-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-libav \
  gstreamer1.0-gl

###############################################################################
# 2. Clone and build ardupilot_gazebo in $HOME
###############################################################################
ARDUPILOT_GZ_DIR="$HOME/ardupilot_gazebo"

if [[ -d "$ARDUPILOT_GZ_DIR/.git" ]]; then
  echo "=== ardupilot_gazebo already cloned at $ARDUPILOT_GZ_DIR ==="
  echo "Skipping clone. To re-clone, remove that directory first."
else
  echo "=== Cloning ardupilot_gazebo into $ARDUPILOT_GZ_DIR ==="
  git clone https://github.com/ArduPilot/ardupilot_gazebo "$ARDUPILOT_GZ_DIR"
fi

echo "=== Building ardupilot_gazebo ==="
cd "$ARDUPILOT_GZ_DIR"
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j"$(nproc)"

###############################################################################
# 3. Append Gazebo environment variables to ~/.bashrc
###############################################################################
echo "=== Configuring Gazebo environment variables in ~/.bashrc ==="

BASHRC="$HOME/.bashrc"
PLUGIN_LINE='export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}'
RESOURCE_LINE='export GZ_SIM_RESOURCE_PATH=$HOME/ardupilot_gazebo/models:$HOME/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}'

add_line_if_missing() {
  local line="$1"
  local file="$2"
  if ! grep -Fxq "$line" "$file" 2>/dev/null; then
    echo "$line" >> "$file"
  fi
}

add_line_if_missing "$PLUGIN_LINE" "$BASHRC"
add_line_if_missing "$RESOURCE_LINE" "$BASHRC"

echo
echo "=== Done ==="
echo "Built ardupilot_gazebo in: $ARDUPILOT_GZ_DIR"
echo "Environment variables added to ~/.bashrc."

