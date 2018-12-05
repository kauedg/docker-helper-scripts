#!/bin/bash

bash stop_docker.sh

[ $? != 0 ] && { echo "\"stop_docker.sh\" script error"; exit 1; }

echo "Starting docker service... "
OUT=$(sudo systemctl start docker 2>&1)

[ $? != 0 ] && { echo "Error starting \"docker\" service."; echo ${OUT}; exit 1; }

echo "OK"

systemctl start docker
