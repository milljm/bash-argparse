#!/bin/bash
function print_arrays()
{
    # This function uses indirect expansion (pass variable name, not the value)
    local _args_array=$1
    local _msgs_array=$2
    local tmp=$_args_array[@]
    local args_array=( "${!tmp}" )
    local tmp=$_msgs_array[@]
    local msgs_array=( "${!tmp}" )
    local max_length=50
    local tab="      "
    local longest_found=""
    local indent=$(printf "%.s " {1..100})

    #justify_array ${!_args_array}

    # Discover longest argument
    for argument in ${args_array[@]}; do
        if [ ${#argument} -gt ${#longest_found} ]; then
            longest_found="${argument}${tab}"
        fi
    done

    # Create indent for about strings based on longest found argument length
    index=0
    for argument in "${args_array[@]}"; do
        args_array[$index]="${argument}${indent::${#longest_found}-${#argument}}"
        let index=$index+1
    done

    index=0
    for message in "${args_array[@]}"; do
        # About string longer than max_length
        message_length=${#msgs_array[$index]}
        if [ $message_length -gt $max_length ]; then

            # Format the message string while longer than max_length
            justified_message=""
            while [ $message_length -gt $max_length ]; do
                # each iteration will contain a new line, with indented spaces to beautify the about message
                justified_message="${justified_message}${msgs_array[$index]::$max_length}\n${tab}${indent::${#longest_found}}"

                # adjust remainder message length to escape while true
                msgs_array[$index]="${msgs_array[$index]:$max_length}"
                message_length=${#msgs_array[$index]}
            done

            # Grab any remainder
            remainder_message="${msgs_array[$index]}"

            # Print formatted string
            echo -e "${tab}${message}${justified_message}${remainder_message}"
        else
            echo -e "${tab}${message}${msgs_array[$index]}"
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
