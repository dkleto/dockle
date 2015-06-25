#! /bin/bash

## TODO: Find a better way to test if variables are already set.

## Map docker image names to container names
if ! declare -p $contnames | grep -iq "Declare -A contnames="; then
    declare -A contnames
    contnames=(
        [$webimage]=$webcont
        [$dbimage]=$dbcont
    )
fi

## Sync time across all containers with the host system
commontime=" -v /etc/localtime:/etc/localtime:ro "

## Map images to docker run arguments
if ! declare -p $contargs | grep -iq "Declare -A contargs="; then
    declare -A contargs
    contargs=(
        [$dbimage]="$commontime $dockreg/$dbimage"
        [$webimage]="$commontime --link $dbcont:$dbcont -v `pwd`/www:/var/www/$sitedir -v `pwd`/logs:/var/log/sitelogs/$sitedir $dockreg/$webimage"
    );
fi

## Identify configuration files and their target destinations
if ! declare -p $configs | grep -iq "Declare -A configs="; then
    declare -A configs
    configs=(
        [config-template.php]="www/config.php"
    );
fi

## Map URLs to docker containers for the purpose of cooking /etc/hosts
if ! declare -p $hostcookery | grep -iq "Declare -A hostcookery="; then
    declare -A hostcookery
    hostcookery=(
        ["$site_url"]="$webcont"
    )
fi

## Define run order of containers (Associative arrays in bash aren't ordered)
if ! declare -p $contorder | grep -iq "Declare -A contorder="; then
    declare -a contorder
    contorder=("$dbimage" "$webimage")
fi

## Identify dirs which need to be checked (These dirs are to be mounted)
if ! declare -p $dirs | grep -iq "Declare -A dirs="; then
    declare -a dirs
    dirs=("`pwd`/logs" "`pwd`/www")
fi
