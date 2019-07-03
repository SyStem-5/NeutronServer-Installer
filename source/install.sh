#!/bin/bash

cd "$(dirname "$0")"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root."
   exit 1
fi

read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: Proceed with Neutron Server installation? [Y/n] ' -r REPLY
REPLY=${REPLY:-y}
echo    #Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    # handle exits from shell or function but don't exit interactive shell
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Waiting for package manager to become available..."
while true
do
    sudo dpkg --configure -a
    if [ $? -eq 0 ]; then
        echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Package manager \e[32m[OK]\e[0m"
        break
    fi
    sleep 1
done

read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: Check and install system updates? [Y/n] ' -r
REPLY=${REPLY:-y}
if [[ $REPLY =~ ^[Yy]$ ]]; then

    sudo apt-get update
    sudo apt-get -y dist-upgrade

    echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Updating complete."
fi

#In case we already have something in root crontab
read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: Reset crontab? [Y/n] ' -r
REPLY=${REPLY:-y}
if [[ $REPLY =~ ^[Yy]$ ]]; then
    crontab -r
fi

neutron_base_loc=/etc/NeutronServer

rm -rf $neutron_base_loc
mkdir -p $neutron_base_loc

chown root:root $neutron_base_loc
chmod 700 $neutron_base_loc

#Run ufw setup script
./ufw/setup.sh

if hash docker 2>/dev/null; then
    echo -e "\e[1m\e[44mLSOC Installer\e[0m: Found Docker installed."
    read -p $'\e[1m\e[44mLSOC Installer\e[0m: Check for a new docker version? [Y/n] ' -r
    REPLY=${REPLY:-y}
    echo    #Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apt -y install docker.io
    fi
else
    echo -e "\e[1m\e[44mLSOC Installer\e[0m: Downloading & Installing the latest Docker version."
    apt -y install docker.io
fi

#Run the Web Interface installation
if ./web_interface/install.sh $neutron_base_loc --self_signed; then
    mkdir /etc/mosquitto
    cp -n mosquitto/mosquitto.conf /etc/mosquitto
    sed -i -e 's/<DB_PASSWORD>/'$(<$neutron_base_loc/webinterface_docker/sql_pass.txt)'/g' /etc/mosquitto/mosquitto.conf
fi

#Run the Mosquitto Broker installation
./mosquitto/install.sh $neutron_base_loc /etc/mosquitto --neus

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Installation Complete."
