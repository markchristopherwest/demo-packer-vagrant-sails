#!/bin/bash
# Setup SailsJS in Node from Repository

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

set -e

readonly href=$1
readonly base="${href%.*}"
readonly repo="$(basename "${base}")"
readonly dude="$(basename "${base%/${repo}}")"

# Using Ubuntu
echo "Package Node"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

# Install NodeJS
echo "Install Node Silently"
sudo apt-get install -y nodejs

# Install Sails using NPM
echo "Install Sails Globally"
sudo npm install -g sails

# Install App Content
echo "Install ${repo} Source"
sudo mkdir -p /var/www
cd /tmp
git clone "$href"
sudo rm -rf /tmp/${repo}/.git
sudo mv /tmp/${repo} /var/www/${repo}
cd /var/www/${repo}
sudo npm i package.json

# Install App Service
echo "Install ${repo} Service"
sudo cat >/tmp/${repo}.service <<EOL
# ${repo} Service Config
[Unit]
Description=${repo}
Documentation=$1
 
[Service]
ExecStart=/usr/bin/node /var/www/${repo}/app.js
Restart=never
User=nobody
# Note Debian/Ubuntu uses 'nogroup', RHEL/Fedora uses 'nobody'
Group=nogroup
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/var/www/${repo}
StandardOutput=null
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL
sudo mv /tmp/${repo}.service /etc/systemd/system/
sudo systemctl start ${repo}
sudo systemctl enable ${repo}