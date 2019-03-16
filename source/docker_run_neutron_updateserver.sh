#!/bin/bash

base_loc=/etc/NeutronServer/neutron_updateserver/

cd $base_loc

#System config for Redis
sudo sysctl vm.overcommit_memory=1
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled

sudo docker-compose up -d --build