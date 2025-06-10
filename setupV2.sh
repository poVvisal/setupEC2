#!/bin/bash

# This All-in-One script prepares a fresh Ubuntu server, clones the project
# repository, and installs all system and application dependencies.

# Exit immediately if any command fails, making the script safer.
set -e

# --- [STEP 1/5] PREPARING SERVER ENVIRONMENT ---
echo "🚀 [1/5] Preparing the server environment..."

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


# --- [STEP 2/5] CLONING YOUR PROJECT REPOSITORY ---
echo "🚀 [2/5] Cloning your Esport_Club project from GitHub..."

# The URL of your repository.
REPO_URL="https://github.com/poVvisal/Esport_Club.git"

# Clone the project in current directory
git clone "$REPO_URL"

# Navigate into the newly created project directory.
cd Esport_Club/

echo "✅ Project code has been cloned."
echo ""


# --- [STEP 3/5] INITIALIZING AND INSTALLING MICROSERVICE DEPENDENCIES ---
echo "🚀 [3/5] Initializing and installing npm packages for each microservice..."

# An array holding the names of your service directories.
MICROSERVICES=(
    "APIGateway_Microservice"
    "Authentication_Microservice"
    "Coach_Microservice"
    "Player_Microservice"
    "Registration_Microservice"
)

# Loop through each microservice directory
for dir in "${MICROSERVICES[@]}"; do
    if [ -d "$dir" ]; then
        echo "--> Setting up [${dir}]..."
        (cd "$dir" && {
            # Initialize npm project with default settings
            npm init -y
            
            # Install dependencies one by one as specified
            npm install express
            npm install jsonwebtoken
            npm install dotenv
            npm install mongoose
        })
        echo "--> ✅ [${dir}] setup complete"
    else
        echo "--> WARNING: Directory [${dir}] not found. Skipping."
    fi
done

echo ""

# --- [STEP 4/5] CREATING SAMPLE .ENV FILES ---
echo "⬇️ [4/5] Creating sample .env files for each microservice..."

# Generate one JWT secret for all services (shared authentication)
SHARED_JWT_SECRET=$(openssl rand -base64 32)

for dir in "${MICROSERVICES[@]}"; do
    if [ -d "$dir" ]; then
        # Create .env file with service-specific database
        cat > "$dir/.env" <<EOF
# Database Configuration
MONGODB_URI=mongodb+srv://user:password@dead-drop-db.shfcaup.mongodb.net/${dir,,}?retryWrites=true&w=majority&appName=dead-drop-db

# Authentication
JWT_SECRET=${SHARED_JWT_SECRET}

# Service Configuration
NODE_ENV=development
EOF
        echo "--> Created .env for [${dir}] with shared JWT secret"
    fi
done

echo ""
echo "✅✅✅ ALL-IN-ONE SETUP COMPLETE! ✅✅✅"
echo "The server is fully prepared with all dependencies including:"
echo "  - Fresh npm initialization for each microservice"
echo "  - Express.js framework for web server functionality"
echo "  - JWT for authentication tokens (shared across services)"
echo "  - dotenv for environment variable management"
echo "  - Mongoose for MongoDB operations"
echo "  - Clean .env files without port conflicts"
echo "You can now configure and launch the services with pm2."
