#!/bin/bash

function SelectAlsaDev() {
    cat /proc/asound/cards 1>&2
    echo -n "Select Sound Device: " 1>&2
    read input
    DEV=$(cat /proc/asound/cards | awk -v L=$input '$1==L && match($0, /\[[^\]^ ]+/) {print substr($0, RSTART+1, RLENGTH-1)}')
    if [ -z "$DEV" ] ; then
        echo 1>&2
        echo "No device matching" 1>&2
        echo 1>&2
        SelectAlsaDev
    else
        echo $DEV
    fi
}

function mpd_add_output() {
cat <<EOF
audio_output {
       type            "alsa"
       name            "$1"
       device          "hw:$1,0"
       mixer_type      "software"
}

EOF
}

DEV=$(SelectAlsaDev)
mpd_add_output $DEV >> mpd.conf

