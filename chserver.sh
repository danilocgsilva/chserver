#!/bin/bash

## version
VERSION="0.0.1"

## Asks again, if no value was given
chserver_asknonempty () {
    read -p "$1" $2

    if [ -z ${!2} ]; then
        echo -- Error! You must provides the asked information.
        chserver_asknonempty "$1" $2
    fi
}

## Asks again, if the value given is not an valid system path file
chserver_askfile () {
    chserver_asknonempty "$1" $2
    
    if [ ! -f ${!2} ]; then
        echo -- Error! The asked information needs to be a file. \"${!2}\" does not exists in the file system.
        chserver_askfile "$1" $2
    fi
}

## Main function
chserver () {
    chserver_askfile "Provides the full sql script: " full_path_sql_script

    chserver_asknonempty "Provides the old domain: " old_domain

    chserver_asknonempty "Provides the new domain: " new_domain

    chserver_asknonempty "Provides the new server: " old_server_path

    chserver_asknonempty "Provides the new server: " new_server_path
    
    echo Full sql script: $full_path_sql_script
    echo Old server: $old_domain
    echo New server: $new_domain
    echo Old server path: $old_server_path
    echo New server path: $new_server_path
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