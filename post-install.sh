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
            sudo usermod -a -G wireshark $USER
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
sudo service docker restart
# add user to group
sudo usermod -aG docker $USER
echo "- Installation of Docker for CORE: Done!"

echo "+ Creating image to be used in CORE as default..."
img_dev="$HOME/devops/docker-images/ubuntu"
mkdir -p $img_dev
echo -e 'FROM ubuntu:latest\nRUN apt-get update\nRUN apt-get install -y iproute2 ethtool gedit sudo iputils-ping' | tee $img_dev/Dockerfile
sudo docker build --network host -t ubuntu:latest $img_dev
echo "- Creation of docker image ubuntu:latest -> Done!"

# install snap packages (usin classic option)
echo "+ Installing snap packages (Eclipse) ..."
# List of apt packages
snap_packages=("eclipse")

for package in "${snap_packages[@]}"; do
    sudo snap install --classic "$package"
    if [ $? -eq 0 ]; then
        echo "-- El paquete $package se ha instalado correctamente."
    else
        echo "-- Error al instalar el paquete $package."
    fi
done
echo "- Installation of snap packages: Done!"

# Install vscode from deb package since there is no snap version for arm chipsets
vscode_link_arm="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
vscode_link_amd="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
cpu_architecture=$(lscpu | grep Architecture | awk '{print $2}')
# Descargar el archivo adecuado basado en la arquitectura
if [ "$cpu_architecture" == "x86_64" ]; then
    wget  $vscode_link_amd -O /tmp/vscode.deb
else
    wget $vscode_link_arm -O /tmp/vscode.deb
fi
sudo apt install /tmp/vscode.deb

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
sudo apt install openjdk-11-jdk maven -y

echo "Do not forget this: After all this installation, a reboot is mandatory!"
