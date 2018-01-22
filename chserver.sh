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

## Do the question. Because question can be asked several times, in case of user error, it is easiest to asks questions by index
chserver_questionindex () {
    if [ -z $1 ]; then
        echo You must give a number of the question index.
        exit
    fi

    case $1 in
        1) chserver_askfile "Provides the full sql script: " full_path_sql_script;;
        2) chserver_asknonempty "Provides the old domain: " old_domain;;
        3) chserver_asknonempty "Provides the new domain: " new_domain;;
        4) chserver_asknonempty "Provides the old server path: " old_server_path;;
        5) chserver_asknonempty "Provides the new server path: " new_server_path;;
    esac
}

## Count occurrences in the given file, so the user can be hinted if errors occurs
chserver_countoccurrences () {
    if [ -z $1 ]; then
        echo Must provide an valid file as argument
        exit
    fi

    count_occurrences=$(grep -iR $1 | wc -l)

    echo There are $count_occurrences in the give file.
}

## Main function
chserver () {
    # Asks for full sql script path
    chserver_questionindex 1 

    # Asks for old domain
    chserver_questionindex 2

    chserver_countoccurrences $old_domain

    # Asks for new domain
    chserver_questionindex 3

    # Asks for old server path
    chserver_questionindex 4

    chserver_countoccurrences $old_server_path

    # Asks for a new server path
    chserver_questionindex 5
    
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