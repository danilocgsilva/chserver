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
        2) read -p "Provides the old domain: " old_domain;;
        3) chserver_asknonempty "Provides the new domain: " new_domain;;
        #4) chserver_asknonempty "Provides the old server path: " old_server_path;;
        4) read -p "Provides the old server path: " old_server_path;;
        5) chserver_asknonempty "Provides the new server path: " new_server_path;;
        *) return 2;;
    esac
}

## Make question when zero was the result of occurrences for domain replacement
chserver_domainzerodecisions () {
    if [ ! -z "$1" ]; then
        echo "$1"
    fi

    echo Answer 1: That\'s right. I wont do any domain replacement.
    echo Answer 2: I mistyped. Ask me again the old domain.
    echo Answer 0: Cancel.
    read -p "Provides the right number: " number_of_resp
    case $number_of_resp in
        1) return 0 ;;
        2) chserver_replacementsdomainasks;;
        0) exit ;;
        *) sleep 2; echo ""; echo "-- Please, provides just a single number to answer." ;chserver_domainzerodecisions "";;
    esac
}

## Make question when zero was the result of occurrences for server path replacement
chserver_serverpathzerodecisions () {
    if [ ! -z "$1" ]; then
        echo "$1"
    fi

    echo Answer 1: That\'s right. I wont do any server path replacement.
    echo Answer 2: I mistyped. Ask me again the old server path.
    echo Answer 0: Cancel.
    read -p "Provides the right number: " number_of_resp
    case $number_of_resp in
        1) return 0 ;;
        2) chserver_replacementsserverpathasks;;
        0) exit ;;
        *) sleep 2; echo ""; echo "-- Please, provides just a single number to answer." ;chserver_serverpathzerodecisions "";;
    esac
}

## Decides the order of questions to the domain replacement operation
chserver_replacementsdomainasks () {
    # Asks for old domain
    chserver_questionindex 2

    if [ -z $old_domain ]; then
        sleep 2
        chserver_domainzerodecisions "-- WARNING! You did not provides anything. What is going on?"
        return 0
    fi

    old_domain_occurrences=$(grep -iR "$old_domain" "$full_path_sql_script" | wc -l)
    if [ $old_domain_occurrences -eq 0 ]; then
        sleep 2
        chserver_domainzerodecisions "-- WARNING! No occurrences found for $old_domain. What is going on?"
        return 0
    fi

    echo "-- There are $old_domain_occurrences occurrences for $old_domain"

    # Asks for new domain
    chserver_questionindex 3
}

## Decides the order of questions to the server path replacement operation
chserver_replacementsserverpathasks () {
    # Asks for old server path
    chserver_questionindex 4

    if [ -z $old_server_path ]; then
        sleep 2
        echo -- WARNING! You did not provides anything. What is going on?
        chserver_serverpathzerodecisions
        return 0
    fi

    old_serverpath_occurrences=$(grep -iR "$old_server_path" "$full_path_sql_script" | wc -l)
    if [ $old_serverpath_occurrences -eq 0 ]; then
        sleep 2
        echo -- WARNING! No occurrences found for $old_server_path. What is going on?
        chserver_serverpathzerodecisions
        return 0
    fi

    echo "There are $old_serverpath_occurrences occurrences for $old_server_path"

    # Asks for new domain
    chserver_questionindex 5
}


## Provides informations to the user, so he can confirm that it's everything right before operations
chserver_finalstatements () {
    echo "-- The full sql script is -----> $full_path_sql_script"

    if [ -z $old_domain ] ; then
        echo "-- Old domain not provided. No domain replacements to perform."
    else
        echo "-- The old domain is ----------> $old_domain"
        echo "-- The new domain is ----------> $new_domain"
    fi

    if [ -z $old_server_path ]; then
        echo "-- Old old server path not provided. No server path replacements to perform."
    else
        echo "-- The old server path is -----> $old_server_path"
        echo "-- The new new server path is -> $new_server_path"
    fi

    echo "-- That's right? Type enter to yes. Type no to ask all again"
    read -p "-> " final_resp
    case $final_resp in
        no) chserver;;
        *) chserver_proceedsreplacements;;
    esac
}

## Procceeds the replacements after user confirmation
chserver_proceedsreplacements () {

    if [ ! -z $old_domain ]; then
        sed -i s@$old_domain@$new_domain@g $full_path_sql_script
    fi

    if [ ! -z $old_server_path ]; then
        sed -i s@$old_server_path@$new_server_path@g $full_path_sql_script
    fi

    echo Done!
}

## Main function
chserver () {
    # Asks for full sql script path
    chserver_questionindex 1 

    chserver_replacementsdomainasks

    chserver_replacementsserverpathasks
    
    chserver_finalstatements
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