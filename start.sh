#! /bin/bash
## Check that the containers aren't already running
running=0
for CONTAINER in "$webcont" "$dbcont"
    do
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
sudo docker rm $webcont
sudo docker rm $dbcont

## Location of code on host machine.
rootdir=`pwd`
hostcodedir=$rootdir/www

## The code and log directories exist already.
if [ ! -d $hostcodedir ]
    then
        echo -e "\nError: The directory $hostcodedir does not exist. You should
        either create this directory and add the $site_url codebase, or
        symlink to this codebase.\n"
        exit 1
fi
if [ ! -d $rootdir/logs ]
    then
        echo "Creating logs directory..."
        mkdir $rootdir/logs
fi

## Run the DB container.
sudo docker run -d --name $dbcont $dockreg/$dbimage

## Copy template config.php to the codebase. First backup existing config.php.
if [ -f $hostcodedir/config.php ]
    then
        if ! diff -q $rootdir/config-template.php $rootdir/www/config.php > /dev/null
            then
                mv $hostcodedir/config.php $rootdir/config-backup.php
                cp $rootdir/config-template.php $hostcodedir/config.php
        fi
    else
        cp $rootdir/config-template.php $hostcodedir/config.php
fi

## Run the web container.
sudo docker run -d --name $webcont --link $dbcont:$dbcont  -v $hostcodedir:/var/www/$sitedir -v $rootdir/logs:/var/log/sitelogs/$sitedir -v /etc/localtime:/etc/localtime $dockreg/$webimage

## Cook hosts file to point to the web container:
web_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $webcont`

## We need to escape periods.
site_url_esc=`echo $site_url | sed -e 's/\./\\\./g'`
web_ip_esc=`echo $web_ip | sed -e 's/\./\\\./g'`

## If the URL is already present, change the IP. If not, add an entry for it.
if grep --quiet $site_url /etc/hosts;  then
    regex="-i 's/^.*$site_url_esc.*$/$web_ip_esc $site_url_esc/' /etc/hosts"
    eval sudo sed "$regex"
else
    echo "## $site_url web container" | sudo tee -a /etc/hosts
    echo "$web_ip $site_url" | sudo tee -a /etc/hosts
fi
