#! /bin/bash
## Check that the containers are running
running=1
for IMAGE in "${!contnames[@]}"
    do
        CONTAINER=${contnames[$IMAGE]}
        if ! `sudo docker ps | grep --quiet $CONTAINER`
            then
                echo "$CONTAINER is not running!"
                running=0
        fi
    done
## If all containers are running, commit them
if [ $running = 1 ]
    then
        for IMAGE in "${!contnames[@]}"
            do
                CONTAINER=${contnames[$IMAGE]}
                echo "Committing $IMAGE"
                sudo docker commit $CONTAINER $dockreg/$IMAGE
            done
else
       echo "Aborting save: one or more containers are not running."
fi

