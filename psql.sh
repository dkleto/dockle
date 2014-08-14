#! /bin/bash

## Get the database login details from the config-template.php:
pattern="s/^.*=\s*['\\\"]\(.*\)['\\\"]\s*;\s*$/\1/"
dbhost=`grep "$CFG\->dbhost" ./config-template.php | sed "$pattern"`
dbname=`grep "$CFG\->dbname" ./config-template.php | sed "$pattern"`
dbuser=`grep "$CFG\->dbuser" ./config-template.php | sed "$pattern"`
## We'll use this env variable to get around interactive password prompt:
export PGPASSWORD=`grep "$CFG\->dbpass" ./config-template.php | sed "$pattern"`
## Work out the IP of the db container:
db_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $dbhost`

if [ -z $db_ip ]
    then
    echo "The database hose $dbhost is not running."
    exit
fi

psql -U $dbuser $dbname -h $db_ip
