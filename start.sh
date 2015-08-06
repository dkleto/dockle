#! /bin/bash
## Check that the containers aren't already running
running=0
for IMAGE in "${!contnames[@]}"
    do
        CONTAINER=${contnames[$IMAGE]}
        if `sudo docker ps | grep --quiet $CONTAINER`
            then
                running=1
                echo "$CONTAINER is already running."
        fi
    done
if [ $running = 1 ]
    then
        exit
fi

## Remove previous containers.
for IMAGE in "${!contnames[@]}"
    do
        CONTAINER=${contnames[$IMAGE]}
        if sudo docker ps -a | grep --quiet "$CONTAINER"
            then
                sudo docker rm $CONTAINER
        fi
    done

missing=0
for DIR in "${!dirs[@]}"
    do
        dirname="${dirs[$DIR]}"
        if [ ! -d $dirname ]
            then
                missing=1
                echo -e "\nError: The directory $dirname is configured to be
                mounted in one of the containers. Make sure that this directory
                exists and is readable."
                exit 1
        fi
    done
if [ $missing = 1 ]
    then
        exit
fi

## Check if data containers exist.
for IMAGE in "${!dataconts[@]}"
    do
        DATACONT=${dataconts[$IMAGE]}
        if sudo docker ps -a  | grep -q "$DATACONT"
            then
                dataconts[$IMAGE]="--volumes-from $DATACONT"
            else
                dataconts[$IMAGE]=""
        fi
    done

## Start the containers
for IMAGE in "${!contorder[@]}"
    do
        image=${contorder[$IMAGE]}
        sudo docker run --name ${contnames[$image]} ${contargs[$image]} ${dataconts[$image]} $dockreg/$image
    done

## Backup configuration files if necessary then copy them in
for CONF in "${!configs[@]}"
    do
        target=${configs[$CONF]}
        if [ -f $target ]
            then
                if ! diff -q $CONF $target > /dev/null
                    then
                        ## Strip the path from the file
                        bufile=`echo $target | sed -e 's/^.*\///'`
                        ## Append "-backup", but keep file extension
                        butarget=`echo $bufile | sed -e 's/\(\.[a-zA-Z]*\)\?$/-backup\1/'`
                        mv $target $butarget
                        cp $CONF $target
                fi
            else
                cp $CONF $target
        fi
    done

## Cook hosts files according to config
for COOK in "${!hostcookery[@]}"
    do
    web_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${hostcookery[$COOK]}`
    ## We need to escape periods.
    site_url_esc=`echo $COOK | sed -e 's/\./\\\./g'`
    web_ip_esc=`echo $web_ip | sed -e 's/\./\\\./g'`

    ## If the URL is already present, change the IP. If not, add an entry for it.
    if grep --quiet $COOK /etc/hosts;  then
        regex="-i 's/^.*$site_url_esc.*$/$web_ip_esc $site_url_esc/' /etc/hosts"
        eval sudo sed "$regex"
    else
        echo "## ${hostcookery[$COOK]} container" | sudo tee -a /etc/hosts
        echo "$web_ip $COOK" | sudo tee -a /etc/hosts
    fi
    done
