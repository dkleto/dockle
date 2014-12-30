#! /bin/bash
## Check that the containers are running
running=1
for CONTAINER in "$webcont" "$dbcont"
    do
        if ! `sudo docker ps | grep --quiet $CONTAINER`
            then
                echo "$CONTAINER is not running!"
                running=0
        fi
    done
## If both containers are running, commit them
if [ $running = 1 ]
    then
       echo "Committing web image"
       sudo docker commit $webcont $dockreg/$webimage
       echo "Committing db image"
       sudo docker commit $dbcont $dockreg/$dbimage
else
       echo "Aborting save: one or more containers are not running."
fi

