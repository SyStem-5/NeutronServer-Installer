#!/bin/bash

build_dir=build/NeutronUpdateServerInstaller

rm -rf $build_dir

mkdir -p $build_dir


rsync -a --info=progress2 source/neutron_updateserver $build_dir
rsync -a --info=progress2 source/ufw_setup $build_dir

rsync -a --info=progress2 source/mosquitto $build_dir
git clone https://github.com/SyStem-5/Mosquitto-Auth-DockerImage.git --recurse-submodules $build_dir/mosquitto/mosquitto_docker

rsync --info=progress2 source/install.sh $build_dir

rsync --info=progress2 source/docker_run_neutron_updateserver.sh $build_dir

rsync -a --info=progress2 ../NeutronServer/ $build_dir/neutron_updateserver/django/app/ \
    --exclude .vscode \
    --exclude .git \
    --exclude __pycache__ \
    --exclude README.md \
    --exclude run_dev_server.sh \
    --exclude set_dev_env_vars.sh \
    --exclude .gitignore

# rsync -a --info=progress2 \
#     ../NeutronServer/version_control $build_dir/neutron_updateserver/django/app/
