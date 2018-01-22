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
        *) return 2;;
    esac
}

## Make question when zero was the result of occurrences for domain replacement
chserver_domainzerodecisions () {
    echo Answer 1: That\'s right. I wont do any domain replacement.
    echo Answer 2: I mistyped. Ask me again the old domain.
    echo Answer 0: Cancel.
    read -p "Provides the right number: " number_of_resp
    case $number_of_resp in
        1) return 0 ;;
        2) chserver_replacementsdomainasks;;
        0) exit ;;
        *) sleep 2; echo Please, provides just a single number to answer. ;chserver_domainzerodecisions;;
    esac
}

## Decides the order of questions to the domain replacement operation
chserver_replacementsdomainasks () {
    # Asks for old domain
    chserver_questionindex 2

    old_domain_occurrences=$(grep -iR "$old_domain" "$full_path_sql_script" | wc -l)
    if [ $old_domain_occurrences -eq 0 ]; then
        sleep 2
        echo -- WARNING! No occurrences found for $old_domain. What is going on?
        chserver_domainzerodecisions
        return 0
    fi

    echo There are $old_domain_occurrences occurrences for $old_domain

    # Asks for new domain
    chserver_questionindex 3
}

## Main function
chserver () {
    # Asks for full sql script path
    chserver_questionindex 1 

    chserver_replacementsdomainasks

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