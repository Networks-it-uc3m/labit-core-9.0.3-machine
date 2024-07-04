# Labit Virtual Machine Installation (CORE)
This repository contains the necessary elements to allow the automated installation of software tools involved in the creation of the Labit virtual machine (VM). Thus, enabling the necessary resources to undertake the laboratories of Audiovisual Services, Computer Networks and Design and Operation of Communication Networks, subjects from the Department of Telematics Engineering of the Universidad Carlos III de Madrid.

## Requirements
* An operational VM with Ubuntu Desktop 22.04.4 (jammy) as Operating System. The Ubuntu image (depending on the host chipset, Intel, ARM, or M1/M2) can be found [here](https://cdimage.ubuntu.com/jammy/daily-live/current/)
* Python 3.9+
* Git

## Quick Start (Install)

The following set of instructions outlines the procedure to install each of the required assets in the labit virtual machine. More information
about this can be found in the follwing link: (http://labit.lab.it.uc3m.es/en/versions) 

```shell
git clone https://github.com/Networks-it-uc3m/labit-core-9.0.3-machine.git
cd labit-core-9.0.3-machine
# install dependencies and run installation tasks
./setup.sh 2>&1 | tee installation.log
# once CORE is installed successfully, install docker and other labit artifacts (such as wireshark, vlc, etc.)
./post-install.sh | tee post_installation.log
```
> **NOTES:** 
> The installation process may take a long time, so be patient. Consider restarting the computer once the installation is complete.

> :warning: This development has been validated using **Linux Ubuntu Desktop 22.04.4 LTS** as Operating System, and **Python v3.10.12**. 

## Documentation & Support
We are leveraging a Wiki where you can find more documentation concerning the ulization of the Labit VM

* [Documentation] (http://labit.lab.it.uc3m.es)




# CORE
One of the software artifacts comprised by the Labit virtual machine is CORE: Common Open Research Emulator. CORE is a tool for emulating
networks on one or more machines. It supports the connection of these emulated networks to live networks, and consists of a GUI for drawing
topologies of lightweight virtual devices, and Python modules for scripting network emulation.

CORE is leveraging GitHub hosted documentation and Discord for persistent
chat rooms. This allows for more dynamic conversations and the
capability to respond faster. Feel free to join us at the link below.

* [CORE Documentation](https://coreemu.github.io/core/)
* [CORE Discord Channel](https://discord.gg/AKd7kmP)

CORE Copyright (c)2005-2022 the Boeing Company. See the LICENSE file included in this distribution.
