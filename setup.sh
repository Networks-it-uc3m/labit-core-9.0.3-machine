#!/bin/bash

PYTHON="${PYTHON:=python3}"
PYTHON_DEP="${PYTHON_DEP:=python3}"

# install pre-reqs using yum/apt
if [ -z "${NO_SYSTEM}" ]; then
  if command -v apt &> /dev/null
  then
    echo "setup to install CORE using apt"
    sudo apt update
    sudo apt install -y ${PYTHON_DEP}-pip ${PYTHON_DEP}-venv
    # adding pre-reqs for ubuntu 
    sudo apt install -y ca-certificates git sudo wget tzdata libpcap-dev libpcre3-dev \
    libprotobuf-dev libxml2-dev protobuf-compiler unzip uuid-dev iproute2 iputils-ping \
    tcpdump x11-xserver-utils
  elif command -v yum &> /dev/null
  then
    echo "setup to install CORE using yum"
    sudo yum install -y ${PYTHON_DEP}-pip
  else
    echo "apt/yum was not found"
    echo "install python3, pip, venv, pipx, and invoke to run the automated install"
    exit 1
  fi
fi

# install tooling for invoke based installation
${PYTHON} -m pip install --user pipx==0.16.4
${PYTHON} -m pipx ensurepath
export PATH=$PATH:~/.local/bin
pipx install invoke==1.4.1
pipx install poetry==1.2.1

# invoke the core installation
inv install 

# Add this to inclue core bins in PATH and enable container GUI
echo 'export PATH="$PATH:/opt/core/venv/bin"' >> $HOME/.bashrc


