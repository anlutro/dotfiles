#!/bin/bash

DIRECTION='right'
DRYRUN=''
DUPLICATE=''

for arg in "$@"; do
    case $arg in
        -c|--copy )
            DUPLICATE='yes'
            ;;
        -d|--dryrun|--dry-run )
            DRYRUN='yes'
            ;;
        -l|--left )
            DIRECTION='left'
            ;;
        -r|--right )
            DIRECTION='right'
            ;;
        * )
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

declare -A outputs
declare -a externals

xrandr_query=$(xrandr -q | grep -v '^\s')
xrandr_connected_outputs=$(echo "$xrandr_query" | grep ' connected ' | cut -d' ' -f1 | sort)
xrandr_disconnected_outputs=$(echo "$xrandr_query" | grep ' disconnected ' | cut -d' ' -f1 | sort)
for output in $(echo "$xrandr_connected_outputs" | grep '^e'); do
    primary_output=$output
    outputs[$output]='--auto --primary'
done
for output in $(echo "$xrandr_connected_outputs" | grep -vF "$primary_output"); do
    externals+=("$output")
done
for output in $xrandr_disconnected_outputs; do
    outputs[$output]='--off'
done

if [ ${#externals[@]} -eq 1 ]; then
    external=${externals[0]}
    if [ "$DUPLICATE" = 'yes' ]; then
        outputs[$external]="--same-as $primary_output"
    else
        if [ "$DIRECTION" = 'right' ]; then
            outputs[$external]="--auto --right-of $primary_output"
        elif [ "$DIRECTION" = 'left' ]; then
            outputs[$external]="--auto --left-of $primary_output"
        else
            echo "Unknown DIRECTION value: $DIRECTION"
            exit 1
        fi
    fi
elif [ ${#externals[@]} -eq 2 ]; then
    outputs[$primary_output]="--off"
    outputs[${externals[0]}]="--auto"

    if [ "$DUPLICATE" = 'yes' ]; then
        outputs[${externals[1]}]="--auto --same-as ${externals[0]}"
    else
        outputs[${externals[1]}]="--auto --${DIRECTION}-of ${externals[0]}"
    fi
elif [ ${#externals[@]} -gt 2 ]; then
    echo "Don't know what to do with ${#externals[@]} displays!"
    exit 1
fi

xrandr_args=""
for output in "${!outputs[@]}"; do
    xrandr_args="$xrandr_args --output $output ${outputs[$output]}"
done

i3_msgs=()
if [ ${#externals[@]} -eq 1 ] && command -v i3-msg >/dev/null && command -v jq >/dev/null; then
    i3_output=$primary_output
    for ws_num in $(i3-msg -t get_workspaces | jq '.[] | .num'); do
        if [ $ws_num -gt 2 ]; then
            i3_output=${externals[0]}
        fi
        i3_msgs+=("[workspace=$ws_num:] move workspace to output $i3_output")
    done
fi

if [ "$DRYRUN" = 'yes' ]; then
    echo xrandr $xrandr_args
    xrandr --dryrun $xrandr_args
    for i3_msg in "${i3_msgs[@]}"; do
        echo i3-msg \'$i3_msg\'
    done
else
    xrandr $xrandr_args
    for i3_msg in "${i3_msgs[@]}"; do
        i3-msg "$i3_msg"
    done

    # if screen size changed, need to re-set the desktop background
    if [ -x $HOME/.fehbg ]; then
        $HOME/.fehbg &
    fi
fi
