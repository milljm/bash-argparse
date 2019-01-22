#!/bin/bash
# This does not yet work on Unix... Need to figure out correct local and declare options.
function justify_array()
{
    # This function uses indirect expansion (pass variable name, not the value)
    variable_name=$1; variable_array="${variable_name}[@]"

    # Will be used globally so we do not need to run additional loops
    declare -g longest_found=""
    declare -g indent="`printf "%.s " {1..100}`"

    # find longest string
    for message in "${!variable_array}"; do
        if [ ${#message} -gt ${#longest_found} ]; then longest_found="${message}   "; fi
    done

    # adjust all strings to match length plus the indent. We will use substitution for speed (no forking)
    index=0
    for message in "${!variable_array}"; do
        declare -g ${variable_name}[$index]="${message}${indent::${#longest_found}-${#message}}"
        let index=$index+1
    done
}

function print_arrays()
{
    # Maximum character length in the about section before a new line occurs
    max_length=50
    tab="      "

    # This function uses indirect expansion (pass variable name, not the value)
    local -n _args_array=$1
    local -n _msgs_array=$2
    justify_array ${!_args_array}

    index=0
    for message in "${_args_array[@]}"; do
        # About string longer than max_length
        message_length=${#_msgs_array[$index]}
        if [ $message_length -gt $max_length ]; then

            # Format the message string while longer than max_length
            justified_message=""
            while [ $message_length -gt $max_length ]; do
                # each iteration will contain a new line, with indented spaces to beautify the about message
                justified_message="${justified_message}${_msgs_array[$index]::$max_length}\n${tab}${indent::${#longest_found}}"

                # adjust remainder message length to escape while true
                _msgs_array[$index]="${_msgs_array[$index]:$max_length}"
                message_length=${#_msgs_array[$index]}
            done

            # Grab any remainder
            remainder_message="${_msgs_array[$index]}"

            # Print formatted string
            echo -e "${tab}${message}${justified_message}${remainder_message}"
        else
            echo -e "${tab}${message}${_msgs_array[$index]}"
        fi
        let index=$index+1
    done
}

function print_help()
{
    # Add as many, and as long as needed without having to manually reformat for justification beautification
    args=("-h|--help"\
          "-f|--foo"\
          "-b|--bar"\
          "-l|--long-named-option"\
          "-s|--short")

    args_about=("Print this message and exit"\
                "Help for foo"\
                "Help for bar"\
                "Very long help description which will be a multi-line event for that longed named option"\
                "Help for -s, demonstrating a new line after a long line event")

    printf "\nSyntax:\n\t./`basename $0`\n\nOptions:\n\n"
    print_arrays args args_about

}

for i in "$@"; do
    case $i in
        -h|--help)
            print_help
            exit 0
            ;;
        -f|--foo)
            foo="$2"
            shift 2
            ;;
        -b|--bar)
            bar="$2"
            shift 2
            ;;
        -l|--long-named-option)
            long_options="$2"
            shift 2
            ;;
    esac
done
