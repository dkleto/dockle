#! /bin/bash

## Search running docker processes for the web and db containers.
webps=`sudo docker ps | grep $webcont`
dbps=`sudo docker ps | grep $dbcont`
wsps=`sudo docker ps | grep $wscont`

for CONTAINER in "$webps" "$dbps" "$wsps"
    do
        ## If the container is running...
        if [ ! -z "$CONTAINER" ]
            then
                ## Get the ID (12 character hash) of the container and kill it.
                sudo docker kill `echo $CONTAINER | sed -e 's/^\([a-za-z0-9]\{12\}\).*$/\1/'`
        fi
    done
