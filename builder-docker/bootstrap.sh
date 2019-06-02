#!/bin/bash
# Setup SailsJS in Node from Repository

set -e

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

readonly href=$1
readonly base="${href%.*}"
readonly repo="$(basename "${base}")"

echo 'export PATH=$PATH:/usr/local/bin' >> $HOME/.bashrc

# Install Prerequisites
echo "Install Prereqs Silently"
apt-get update -y
apt-get install -y curl git

# Using Ubuntu
echo "Package Node"
curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Install NodeJS
echo "Install Node Silently"
apt-get install -y nodejs

# Upgrade Managed Packages
echo "Upgrade Managed Packages"
apt-get upgrade -y

# Install MVC Framework
echo "NPM Install SailsJS"
npm i -g sails

# Install App Content
echo "NPM Install /var/www/${repo}/package.json"
mkdir -p /var/www

# Clean & Clone & Clean Again
rm -rf /var/www/*
cd /var/www
git clone ${href}
cd /var/www/${repo}

# Remove Git
rm -rf /var/www/${repo}/.git
npm i package.json

# Create Start Script
cat >/var/www/${repo}.sh <<EOL
#!/bin/bash
# Start ${repo} script
node /var/www/${repo}.sh > /dev/null 2>&1
EOL
chmod +x /var/www/${repo}.sh