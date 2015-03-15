#! /bin/bash

## Stop each running container
for CONTAINER in "${!contnames[@]}"

    do
        if sudo docker ps | grep --quiet ${contnames[$CONTAINER]}
            then
                sudo docker kill ${contnames[$CONTAINER]}
        fi
    done
