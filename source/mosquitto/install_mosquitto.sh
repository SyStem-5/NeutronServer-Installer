#!/bin/bash

mqtt_base_loc=/etc/mosquitto
neutron_server_base_loc=/etc/NeutronServer/

mosquitto_container_local=mosquitto/mosquitto.tar

usrmqttgroup="mqttcontainergroup"
usrmqtt="usrmqttcontainer"

groupadd $usrmqttgroup -g 1003
useradd $usrmqtt -u 1003

usermod -a -G $usrmqttgroup $usrmqtt

pass=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo)
echo "$usrmqtt:$pass" | sudo chpasswd

mkdir $mqtt_base_loc

#Copy the default configuration file so we can make sure the broker is restricted to localhost and set the permissions
#Also, don't overwrite if a config file exists already
cp -r -n mosquitto/mosquitto.conf $mqtt_base_loc

#Make the directory and everything in it root:rw usrmqttcontainer:r
chown -R root:$usrmqttgroup $mqtt_base_loc
chmod -R 640 $mqtt_base_loc

#Copy mosquitto docker run script
cp mosquitto/docker_run_mosquitto.sh $neutron_server_base_loc

echo -e "\e[1m\e[45mMosquitto Installer\e[0m: Downloading & Building Mosquitto container."
cd mosquitto/mosquitto_docker/
docker build -t mosquitto .

#On first run; Run the Mosquitto docker image as "usrmqttcontainer" user pointing to the config file in /etc/mosquitto
mosquitto_conf_file_loc=/etc/mosquitto/mosquitto.conf
docker run --user 1003:1003 --restart on-failure -d \
    -p 0.0.0.0:8883:8883 \
    -v $mosquitto_conf_file_loc:/mqtt/config/mosquitto.conf \
    --name mqtt \
    mosquitto
#--net=webinterfacedocker_mosquitto_network \
#Make crontab start the script(as root) on reboot so it starts even when no one is logged in
(crontab -l 2>/dev/null; echo "@reboot /bin/sh /etc/NeutronServer/docker_run_mosquitto.sh") | crontab -

echo -e "\e[1m\e[45mMosquitto Installer\e[0m: Installation Complete."
