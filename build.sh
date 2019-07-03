#!/bin/bash

build_dir=build/NeutronUpdateServerInstaller

# Try to remove the build directory
rm -rf $build_dir

# Create the build directory
mkdir -p $build_dir

# Base install script
rsync --info=progress2 source/install.sh $build_dir

# Firewall setup script
rsync --info=progress2 ../LSOC-Installer/source/ufw/setup.sh $build_dir/ufw/


## Mosquitto ##

# Copy the install script from LSOC-Installer
rsync -a --info=progress2 ../LSOC-Installer/source/mosquitto $build_dir

# Copy the configuration
rsync --info=progress2 source/mosquitto/mosquitto.conf $build_dir/mosquitto

# Get the mosquitto docker files
rsync -a --info=progress2 ../Mosquitto-Auth-DockerImage/ $build_dir/mosquitto/mosquitto_docker \
    --exclude .vscode \
    --exclude .git \
    --exclude .gitignore \
    --exclude .gitmodules

# Copy the authentication plugin
rsync -a --info=progress2 ../Mosquitto-Auth-Plugin/ $build_dir/mosquitto/mosquitto_docker/Mosquitto-Auth-Plugin \
    --exclude .vscode \
    --exclude .git \
    --exclude .gitignore \
    --exclude .gitmodules


## Web Interface ##

# Copy the install script from LSOC-Installer
rsync -a --info=progress2 ../LSOC-Installer/source/web_interface $build_dir \
    --exclude nginx.conf \
    --exclude docker-compose.yml

# Copy the WebApp docker images
rsync -a --info=progress2 ../WebApp-Docker/ $build_dir/web_interface/webinterface_docker \
    --exclude .git \
    --exclude README.md

# Copy our docker-compose file and nginx configuration
rsync --info=progress2 source/web_interface/nginx.conf $build_dir/web_interface/webinterface_docker/nginx/
rsync --info=progress2 source/web_interface/docker-compose.yml $build_dir/web_interface/webinterface_docker/

# Copy the actual django web application NEUS
rsync -a --info=progress2 ../NeutronServer/ $build_dir/web_interface/webinterface_docker/django/app/ \
    --exclude .vscode \
    --exclude .git \
    --exclude __pycache__ \
    --exclude README.md \
    --exclude run_dev_server.sh \
    --exclude set_dev_env_vars.sh \
    --exclude .gitignore

# Copy the version file to the base dir two levels lower
mv $build_dir/web_interface/webinterface_docker/django/app/webinterface.version $build_dir/web_interface/webinterface_docker
