#!/bin/bash

build_dir=build/NeutronUpdateServerInstaller

# Try to remove the build directory
rm -rf $build_dir

# Create the build directory
mkdir -p $build_dir

# Base install script
rsync --info=progress2 source/install.sh $build_dir

# Firewall setup script
rsync -a --info=progress2 source/ufw_setup $build_dir

# Docker run command script
rsync --info=progress2 source/docker_run_neutron_updateserver.sh $build_dir

# Copy the docker files for the webapp
rsync -a --info=progress2 source/neutron_updateserver $build_dir

# Mosquitto
rsync -a --info=progress2 source/mosquitto $build_dir
rsync -a --info=progress2 ../Mosquitto-Auth-DockerImage/ $build_dir/mosquitto/mosquitto_docker \
    --exclude .vscode \
    --exclude .git \
    --exclude .gitignore \
    --exclude .gitmodules \
    --exclude docker_run.sh
rsync -a --info=progress2 ../Mosquitto-Auth-Plugin/ $build_dir/mosquitto/mosquitto_docker/Mosquitto-Auth-Plugin \
    --exclude .vscode \
    --exclude .git \
    --exclude .gitignore \
    --exclude .gitmodules

# Copy the webapp files
rsync -a --info=progress2 ../NeutronServer/ $build_dir/neutron_updateserver/django/app/ \
    --exclude .vscode \
    --exclude .git \
    --exclude __pycache__ \
    --exclude README.md \
    --exclude run_dev_server.sh \
    --exclude set_dev_env_vars.sh \
    --exclude .gitignore
