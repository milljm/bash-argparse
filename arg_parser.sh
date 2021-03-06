#!/bin/bash
function print_arrays()
{
    #### This function uses indirect expansion (pass variable name, not the value)
    ##
    ## Syntax:  print_arrays args args_about
    ##
    ## Where args and args_about are arrays containing double quoted content:
    ##
    ##   args=("-h|--help"\
    ##         "-a|--absolute [INT]"\
    ##         "-b|--bool-option")
    ##
    ##   args_about=("Pring this message and exit"\
    ##               "-a does this"\
    ##               "-b does that")
    ##
    ## Note: Line Continuations "\" are _required_ when building multi-argument help systems
    ####

    ## The desired maximium about text length, before justification occurs
    local max_length=40

    ## The desired 'tab' length which separates the argument from argument discription
    local tab="   "

    #### End user customizations
    local _args_array=$1
    local _msgs_array=$2
    local _tmp=$_args_array[@]
    local _args_array=( "${!_tmp}" )
    local _tmp=$_msgs_array[@]
    local _msgs_array=( "${!_tmp}" )
    local _longest_found=""
    local _indent=$(printf "%.s " {1..100})

    # Discover longest argument
    for argument in "${_args_array[@]}"; do
        if [ ${#argument} -gt ${#_longest_found} ]; then
            _longest_found="${argument}${tab}"
        fi
    done

    # Create indent for about strings based on longest found argument length
    index=0
    for argument in "${_args_array[@]}"; do
        _args_array[$index]="${argument}${_indent::${#_longest_found}-${#argument}}"
        let index=$index+1
    done

    index=0
    for message in "${_msgs_array[@]}"; do
        message_length=${#_msgs_array[$index]}

        # About string longer than max_length
        if [ $message_length -gt $max_length ]; then
            justified_message=""

            # Format the message string while it is longer than max_length (this method continues to widdle down message_length)
            while [ $message_length -gt $max_length ]; do
                tmp_char_index=$max_length
                # Move backwards to detect a space separated word. If we hit the floor, move forwards instead
                while [ "${_msgs_array[$index]:$tmp_char_index:1}" != " " ] && [ -z "$move_forwards_instead" ]; do
                    let tmp_char_index=$tmp_char_index-1
                    # We hit the floor
                    if [ $tmp_char_index -le 0 ]; then
                        move_forwards_instead=true
                        let tmp_char_index=$max_length+1
                        while [ "${_msgs_array[$index]:$tmp_char_index:1}" != " " ]; do
                            # Catch end of string condition
                            if [ $tmp_char_index -ge ${#_msgs_array[$index]} ]; then break; fi
                            let tmp_char_index=$tmp_char_index+1
                        done
                    fi
                done
                unset move_forwards_instead
                let index_max_length=$tmp_char_index

                # Where the magic happens. Append the new line with the proper lengthed spaces to justify the about text
                justified_message="${justified_message}${_msgs_array[$index]::$index_max_length}\n${tab}${_indent::${#_longest_found}}"

                # Move forwards until we don't hit a space
                while [ "${_msgs_array[$index]:$index_max_length:1}" = " " ]; do
                    # Catch end of string condition
                    if [ $index_max_length -ge ${#_msgs_array[$index]} ]; then break; fi
                    let index_max_length=$index_max_length+1
                done

                # Consume/advance our position within the message, so we eventually exit this while loop
                _msgs_array[$index]="${_msgs_array[$index]:$index_max_length}"
                message_length=${#_msgs_array[$index]}

            done
            # Consume last part of message as we exit the while loop
            remainder_message="${_msgs_array[$index]}"

            # Print beautified message string
            echo -e "${tab}${_args_array[$index]}${justified_message}${remainder_message}\n"
        else
            # Print as-is, no formatting was required
            echo -e "${tab}${_args_array[$index]}${_msgs_array[$index]}"
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
          "-s|--short [TYPE]"\
          "-r|--resume"\
          "-s|--short")

    args_about=("Print this message and exit"\
                "Help for foo"\
                "Help for bar"\
                "Very long help description which will be a multi-line event for that longed named option"\
                "Help for -s, demonstrating a new line after a long line event"\
                "Short help description"\
                "Short again")

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

