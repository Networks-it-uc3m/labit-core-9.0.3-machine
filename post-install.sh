#!/bin/bash

# install apt packages 
echo "+ Installing required apt packages (vlc, wireshark, pimd, kamailio) ..."
# List of apt packages
apt_packages=("vlc" "wireshark" "pimd" "kamailio" "tcpdump" "openssh-server" "traceroute" "wget")

for package in "${apt_packages[@]}"; do
    if [ "$package" = "wireshark" ]; then
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "$package"
    if [ $? -eq 0 ]; then
        echo "-- El paquete $package se ha instalado correctamente."
        # Disabling automatic service start for kamailio and pimd
        if [ "$package" = "pimd" ] || [ "$package" = "kamailio" ]; then
            sudo systemctl stop $package
            sudo systemctl disable $package
        # Enabling non-root user to sniff traffic
        elif [ "$package" = "wireshark" ]; then
            sudo usermod -a -G wireshark $LOCAL_USER
        fi
    else
        echo "-- Error al instalar el paquete $package."
    fi
done
sudo apt autoremove -y
echo "- Installation of apt packages: Done!"

# install docker
echo "+ Installing Docker engine..."
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker assets:
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Modify docker defaults
sudo sh -c 'echo "{\n  \"bridge\": \"none\",\n  \"iptables\": false\n}" > /etc/docker/daemon.json'

# add user to group
sudo usermod -aG docker $USER

# to get this change to take effect, log out and back in or run the following
newgrp docker

echo "- Installation of Docker for CORE: Done!"

# install snap packages (usin classic option)
echo "+ Installing snap packages (VistualStudio and Eclipse) ..."
# List of apt packages
snap_packages=("code" "eclipse")

for package in "${snap_packages[@]}"; do
    sudo snap install --classic "$package"
    if [ $? -eq 0 ]; then
        echo "-- El paquete $package se ha instalado correctamente."
    else
        echo "-- Error al instalar el paquete $package."
    fi
done
echo "- Installation of snap packages: Done!"

# Installing sipp v3.6.0:
echo "+ Installing sipp v3.6.0 ..."
sudo wget -P /opt/ https://github.com/SIPp/sipp/releases/download/v3.6.0/sipp-3.6.0.tar.gz
sudo tar -xvf /opt/sipp-3.6.0.tar.gz -C /opt/
sudo rm /opt/sipp-3.6.0.tar.gz
cd /opt/sipp-3.6.0/
./configure
make
sudo cp sipp /usr/local/bin/
echo "- Installation of sipp v3.6.0: Done!"

# Installing JAVA 11 (compatible for ARM and AMD chipsets)
echo "+ Installing JAVA (openjdk-11-jdk) ..."



echo "Do not forget this: After all this installation, a reboot is mandatory!"
