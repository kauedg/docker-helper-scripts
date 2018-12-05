#!/bin/bash

#TODO: Remove only docker-related bridges
#docker_brs_ids=( $(docker network ls | tail -n +2 | grep "bridge" | grep -Po "^.*?\s\s") )
#docker_brs_names=( $(docker network inspect bridge -f "{{ index .Options \"com.docker.network.bridge.name\" }}") )
#for br_id in ${docker_brs_ids[@]}; do
#  echo ${br_id}
#  docker network inspect ${br_id} -f "{{ index .Options \"com.docker.network.bridge.name\" }}"
#done

sudo systemctl stop docker
sleep 2

function remove_bridges {
  # List all bridges
  br_ifs=( $(brctl show | tail -n +2 | grep -Po "^.*?\t") )

  echo "Bridge interfaces number: ${#br_ifs[@]}"

  [ ${#br_ifs[@]} == 0 ] && { echo "No bridge interfaces found"; exit 0; }

  for br in ${br_ifs[@]}; do

    echo "BRIDGE ${br} ***"

    # Check if interface is enabled
    br_state=$(ip link show ${br} | grep -Po "state \K.*? ")
    if [ "${br_state}" == "UP" ]; then

      echo -n "Disabling bridge... "
      sudo ip link set down dev ${br}
      OUT=$(sudo ip link set down dev ${br} 2>&1)

      [ $? != 0 ] && { echo "Error while disabling bridge interface \"${br}\""; echo ${OUT}; exit 2; }

      echo -e "OK"
    else
      echo "Interface already in \"DOWN\" state"
    fi

    echo -n "Removing bridge... "
    OUT=$(sudo ip link delete dev ${br} 2>&1)

    [ $? != 0 ] && { echo "Error while removing bridge interface \"${br}\""; echo ${OUT}; exit 3; }

    echo "OK"

    echo -e "\n"
  done
}

remove_bridges

exit 0
