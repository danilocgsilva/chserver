#!/bin/bash

## version
VERSION="0.0.1"

chserver_asknonempty () {
    read -p "$1" $2

    if [ -z ${!2} ]; then
        echo -- Error! You must provides the asked information.
        chserver_asknonempty "$1" $2
    fi
}

chserver_askfile () {
    chserver_asknonempty "$1" $2
    
    if [ ! -f ${!2} ]; then
        echo -- Error! The asked information needs to be a file. \"${!2}\" does not exists in the file system.
        chserver_askfile "$1" $2
    fi
}

chserver () {
    #read -p "Provides the full path from sql script: " full_path_sql_script
    #echo $full_path_sql_script
    chserver_askfile "Provides the full sql script: " full_path_sql_script
    echo $full_path_sql_script

    read -p "Provides the old server: " old_server
    echo $old_server
}

## detect if being sourced and
## export if so else execute
## main function with args
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f chserver
else
  chserver "${@}"
  exit $?
fi