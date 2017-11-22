#! /bin/bash

## Run the approprate script based on arguments.
## This script is intended to be run from the parent dir.
for ARG in $*
    do
        case $ARG in
            start)
            . ./scripts/start.sh
            exit
            ;;
            stop)
            . ./scripts/stop.sh
            exit
            ;;
            restart)
            . ./scripts/stop.sh
            . ./scripts/start.sh
            exit
            ;;
            psql)
            . ./scripts/psql.sh
            exit
            ;;
            pg_dump)
            . ./scripts/psql.sh -d
            exit
            ;;
            sh)
            . ./scripts/shell.sh
            exit
            ;;
            *)
            continue
        esac
    done

## Start environment if no arguments passed.
. ./scripts/start.sh
