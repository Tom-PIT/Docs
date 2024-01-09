#!/bin/bash

echo "Welcome to the Tom PIT platform install script. This script will set up your development machine to the point of the first platform run."
read -p "Please enter the path into which to install the first start repository: " installPath

##Ensure install folder exists and is empty
mkdir -p $installPath
cd $installPath

## Add repo and install packages
echo "Updating dependencies"
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## Install Docker desktop
echo "Installing docker"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

## Install Git
echo "Installing Git"
sudo apt-get install git -y

## Clone repo and open explorer
echo "Cloning repository"
if [ -d "$installPath/Docs" ]; then
  cd Docs
  git pull
  cd GettingStarted/src/Compose
else
  git clone https://github.com/Tom-PIT/Docs.git
  cd Docs/GettingStarted/src/Compose
fi

ls -la

## Complete
echo "Setup complete. Press Enter to continue..."
read 
