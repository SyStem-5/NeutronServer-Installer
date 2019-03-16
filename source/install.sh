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
        echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Package manager \e[32mOK\e[0m"
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

neutron_base_loc=/etc/NeutronServer/
rm -rf $neutron_base_loc/neutron_updateserver
mkdir -p $neutron_base_loc

chown root:root $neutron_base_loc
chmod 700 $neutron_base_loc

#Run ufw setup script
./ufw_setup/firewall_setup.sh

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Installing docker."
apt install -y docker.io

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Installing docker-compose."
apt install -y docker-compose

#Run Mosquitto container installation
./mosquitto/install_mosquitto.sh

#Copy the script for running the docker container
cp docker_run_neutron_updateserver.sh $neutron_base_loc

#Copy the docker app to $bb_config_base_loc
cp -r neutron_updateserver $neutron_base_loc

cd $neutron_base_loc

chown root:root neutron_updateserver
chmod 740 neutron_updateserver

cd neutron_updateserver/

secret_key=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 50 | tr -d '\n'; echo)
echo $secret_key >> secret_key.txt

echo "postgres" >> sql_user.txt
sql_pass=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 15 | tr -d '\n'; echo)
echo $sql_pass >> sql_pass.txt

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Loading Docker container."
docker-compose up -d --build

#Add SQL Password to mosquitto configuration file
sed -i -e 's/<DB_PASSWORD>/'$sql_pass'/g' /etc/mosquitto/mosquitto.conf

read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: Set Neutron Update Server Username. Press [ENTER] for [admin] ' -r username
username=${username:-admin}

read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: Set Neutron Update Server Email. Press [ENTER] to skip. ' -r email

pass=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 10 | tr -d '\n'; echo)

docker exec -i -t $(sudo docker ps -aqf "name=neutron_webinterface_django") /bin/ash -c \
"echo \"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$username', '$email', '$pass')\" | pipenv run python manage.py shell"

read -p $'\e[1m\e[44mNeutron Server Installer\e[0m: \e[4mIT IS NOT RECOMMENDED TO KEEP A DIGITAL COPY OF THIS PASSWORD!\e[0m \n Neutron Update Server superuser password: '"[$pass]."$'\nPress [ENTER] to continue. ' -r

#Make crontab start the script(as root) on reboot so it starts even when no one is logged in
(crontab -l 2>/dev/null; echo "@reboot /bin/sh /etc/NeutronServer/docker_run_neutron_updateserver.sh") | crontab -

echo -e "\e[1m\e[44mNeutron Server Installer\e[0m: Installation Complete."
