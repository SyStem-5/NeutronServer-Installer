#!/bin/bash

build_dir=build/NeutronUpdateServerInstaller

rm -rf $build_dir

mkdir -p $build_dir


rsync -a --info=progress2 source/neutron_updateserver $build_dir
rsync -a --info=progress2 source/ufw_setup $build_dir
rsync -a --info=progress2 source/mosquitto $build_dir

rsync --info=progress2 source/install.sh $build_dir

rsync --info=progress2 source/docker_run_neutron_updateserver.sh $build_dir


rsync --info=progress2 \
    ../NeutronServer/Pipfile $build_dir/neutron_updateserver/django/

rsync --info=progress2 \
    ../NeutronServer/Pipfile.lock $build_dir/neutron_updateserver/django/

rsync --info=progress2 \
    ../NeutronServer/manage.py $build_dir/neutron_updateserver/django/app/

rsync -a --info=progress2 \
    ../NeutronServer/NeutronServer $build_dir/neutron_updateserver/django/app/ \
    --exclude __pycache__

rsync -a --info=progress2 \
    ../NeutronServer/static $build_dir/neutron_updateserver/django/app/

rsync -a --info=progress2 \
    ../NeutronServer/templates $build_dir/neutron_updateserver/django/app/

rsync -a --info=progress2 \
    ../NeutronServer/update_manager $build_dir/neutron_updateserver/django/app/

# rsync -a --info=progress2 \
#     ../NeutronServer/version_control $build_dir/neutron_updateserver/django/app/
