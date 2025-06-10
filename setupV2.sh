set -euo pipefail

echo "🚀 [1/4] Preparing the server environment..."

sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential

echo "--> Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "--> Installing global Node.js tools (npm, pm2)..."
sudo npm install -g npm@latest
sudo npm install -g pm2

echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"
echo ""

echo "🚀 [2/4] Installing MongoDB Community Edition..."
sudo apt install -y mongodb
sudo systemctl enable mongodb
sudo systemctl start mongodb
echo "✅ MongoDB status:"
sudo systemctl status mongodb --no-pager
echo ""

echo "🚀 [3/4] Cloning your Esport_Club project from GitHub..."

REPO_URL="https://github.com/poVvisal/Esport_Club.git"
git clone "$REPO_URL"
cd Esport_Club/

echo "✅ Project code has been cloned."
echo ""

echo "🚀 [4/4] Installing npm packages for each microservice..."

SERVICES_DIRS=(
    "APIGateway_Microservice"
    "Admin_Microservice"
    "Authentication_Microservice"
    "Coach_Microservice"
    "Player_Microservice"
    "Registration_Microservice"
)

for dir in "${SERVICES_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "--> Installing dependencies for [$dir]..."
        (cd "$dir" && npm install)
    fi
done

echo ""
echo "🚀 Creating sample .env files for each microservice..."

for dir in "${SERVICES_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        cat > "$dir/.env" <<EOF
MONGODB_URI=mongodb://localhost:27017/${dir,,}
JWT_SECRET=yourSuperSecretKey
EOF
        echo "--> Created .env for [${dir}]"
    fi
done

echo ""
echo "✅✅✅ ALL-IN-ONE SETUP COMPLETE! ✅✅✅"
echo "The server is fully prepared. You can now configure and launch the services with pm2."
