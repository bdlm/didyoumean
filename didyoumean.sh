#!/usr/bin/env bash

# didyoumean error manager
__didyoumean() {
    local tmpfile=$(mktemp)
    local thatswhatimeant=0
    orig_cmd=$2
    "$@" 2> $tmpfile
    exit_code=$?
    dym_errors=$(cat $tmpfile)
    rm -f $tmpfile
    if [ "" != "$exit_code" ] && [ "0" != "$exit_code" ]; then
        # Display a menu for "did you mean" error suggestions
        if [ "" != "$(echo "$dym_errors" | egrep -i "(Did you mean)|(The most similar command)")" ]; then
            local -a options
            reading_options=0
            while read -r line; do
                line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
                if [ "" = "$line" ]; then
                    reading_options=0
                fi
                if [ 1 -eq $reading_options ]; then
                    options+=($line)
                fi
                if [ "" != "$(echo "$line" | egrep -i "(Did you mean)|(The most similar command)")" ]; then
                    reading_options=1
                fi
            done <<< "$dym_errors"

            # rebuild error output
            bad_command=$(echo "$dym_errors" | awk -F "'" '{print $2}')
            >&2 echo "$2: '$bad_command' is not a $2 command. See '$2 --help'."
            >&2 echo

            # build error screen
            if [ 1 -eq "${#options[@]}" ]; then
                >&2 echo "    Did you mean this?"
            else
                >&2 echo "    Did you mean one of these?"
            fi

            # build menu items
            local cnt=0
            for a in "${options[@]}"; do
                if [ 1 -eq "${#options[@]}" ]; then
                    opt_key=""
                else
                    opt_key="$((cnt + 1)):"
                fi
                >&2 echo "        $opt_key ${options[$cnt]}"
                cnt=$((cnt + 1))
            done
            >&2 echo

            # prompt for input
            old_IFS=$IFS
            IFS='%'
            if [ 1 -eq $cnt ]; then
                prompt="[Y/n] > "
            else
                >&2 echo "        0: quit"
                >&2 echo
                prompt="[1] > "
            fi
            read -e -p $prompt -t 60 option
            IFS=$old_IFS

            # if input is not no/quit
            if [ "0" = "$option" ] || [ "n" = "$option" ] || [ "N" = "$option" ] || [ "q" = "$option" ]; then
                option="quit"
                # set default option if none given
            elif [ "" = "$option" ] || [ "Y" = "$option" ] || [ "y" = "$option" ]; then
                option=0
            elif [ "$option" ] && [ -z "${option//[0-9]}" ]; then
                # exec
                option=$((option - 1))
            else
                option="quit"
            fi
            if [ "quit" = "$option" ]; then
                echo "quit."
            else
                echo "executing $1 $2 ${options[$option]} ${@:4}"
                echo
                $1 $2 ${options[$option]} ${@:4}
                thatswhatimeant=1
            fi
        else
            echo "$dym_errors"
            return $exit_code
        fi
    fi
}
export -f __didyoumean
