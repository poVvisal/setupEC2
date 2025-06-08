#!/bin/bash

# This All-in-One script prepares a fresh Ubuntu server, clones the project
# repository, and installs all system and application dependencies.

# Exit immediately if any command fails, making the script safer.
set -e

# --- [STEP 1/3] PREPARING SERVER ENVIRONMENT ---
echo "🚀 [1/3] Preparing the server environment..."

# Update all existing server packages.
sudo apt update && sudo apt upgrade -y

# Install core tools: git, curl, and build-essential for compiling some packages.
sudo apt install -y git curl build-essential

# Install the latest Long-Term Support (LTS) version of Node.js.
echo "--> Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Upgrade npm and install essential global packages like pm2.
echo "--> Installing global Node.js tools (npm, pm2)..."
sudo npm install -g npm@latest
sudo npm install -g pm2

echo "✅ Environment setup is complete."
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo ""


# --- [STEP 2/3] CLONING YOUR PROJECT REPOSITORY ---
echo "🚀 [2/3] Cloning your Esport_Club project from GitHub..."

# The URL of your repository.
REPO_URL="https://github.com/poVvisal/Esport_Club.git"

# Clone the project.
git clone "$REPO_URL"

# Navigate into the newly created project directory.
cd Esport_Club/

echo "✅ Project code has been cloned."
echo ""


# --- [STEP 3/3] INSTALLING ALL MICROSERVICE DEPENDENCIES ---
echo "🚀 [3/3] Installing npm packages for each microservice..."

# An array holding the names of your service directories.
SERVICES_DIRS=(
    "APIGateway_Microservice"
    "Admin_Microservice"
    "Authentication_Microservice"
    "Coach_Microservice"
    "Player_Microservice"
    "Registration_Microservice"
)

# Loop through the array and run 'npm install' in each directory.
for dir in "${SERVICES_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "--> Installing dependencies for [${dir}]..."
        (cd "$dir" && npm install)
    else
        echo "--> WARNING: Directory [${dir}] not found. Skipping."
    fi
done

echo ""
echo "✅✅✅ ALL-IN-ONE SETUP COMPLETE! ✅✅✅"
echo "The server is fully prepared. You can now configure and launch the services with pm2."
