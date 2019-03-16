#!/bin/bash

sudo docker network connect neutronupdateserver_mosquitto_network mqtt

sudo docker container start mqtt