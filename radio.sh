#!/bin/bash

export RR_IMAGE="radio_relay:0.1"
export MPD_IMAGE="mpd:0.1"

export WEB_PORT=9000
export MPD_PORT=6600

export IP_ADDR=
export MPD_PORT_CONTAINER=6600
export BUILD_NUMBER=$(date +%s)
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
TIME=$(date +%Y%m%dT%H%M%S%z)

function SelectIPaddress() {
    ip -4 address | cat 1>&2
    echo -n "Select IP address: " 1>&2
    read input
    IP_ADDR=$(ip -4 -o address | awk -v L=$input: '$1==L && match($4, /^[0-9\.]+/) {print substr($4, RSTART, RLENGTH)}')
    if [ -z "$IP_ADDR" ] ; then
        echo 1>&2
        echo "No address matching" 1>&2
        echo 1>&2
        SelectIPaddress
    else
        echo $IP_ADDR
    fi
}

function AddMPDSettings(){
cat <<EOF

audio_output {
    type        "httpd"
    name        "HTTP Stream"
    encoder     "vorbis"        # optional
    port        "8000"
#   quality     "5.0"           # do not define if bitrate is defined
    bitrate     "128"           # do not define if quality is defined
    format      "44100:16:2"
    always_on   "yes" # prevent MPD from disconnecting all listeners when playback is stopped.
    tags        "yes" # httpd supports sending tags to listening streams.
}

EOF
}

while getopts f OPT
do
  case $OPT in
    "f" ) force_rebuild="TRUE" ;;
  esac
done

shift $(expr $OPTIND - 1)

case $1 in
    "setup")
        export IP_ADDR=$(SelectIPaddress)
        echo "ip address: $IP_ADDR"
        echo "user id: $USER_ID"
        echo "group id: $GROUP_ID"

        oldrrimage=$(sudo docker image ls -q $RR_IMAGE)
        oldmpdimage=$(sudo docker image ls -q $MPD_IMAGE)

        if [ -z "$oldrrimage" ] || [ -n "$force_rebuild" ]; then
            echo $BUILD_NUMBER > nginx/build_number
        fi
        sudo -E docker-compose rm -s -f
        sudo -E docker-compose build
        newrrimage=$(sudo docker image ls -q $RR_IMAGE)
        newmpdimage=$(sudo docker image ls -q $MPD_IMAGE)
        id=$(docker image ls -qf "label=stage=radio_relay-build" | head -n 1)
        sudo docker tag $id radio_relay-build

        if [ "$oldrrimage" != "$newrrimage" ]; then
            if [ -n "$oldrrimage" ]; then
                echo "removing old radio_relay image : $oldrrimage"
                sudo docker rmi -f $oldrrimage > /dev/null
            fi

            if [ -s data/db.sqlite3 ]; then
                cp -rp data data.$TIME
            fi

            id=$(sudo docker create $RR_IMAGE)
            sudo docker cp $id:/code/app/radio/local_settings.py data/
            sudo docker cp $id:/code/app/db.sqlite3 data/
            sudo docker rm $id
            sudo chown $USER_ID.$GROUP_ID data/*
            chmod 600 data/local_settings.py
        fi

        if [ "$oldmpdimage" != "$newmpdimage" ]; then
            if [ -z "$oldmpdimage" ]; then
                id=$(sudo docker create $MPD_IMAGE)
                sudo docker cp $id:/etc/mpd.conf .
                sudo docker rm $id
                sudo chown $USER_ID.$GROUP_ID mpd.conf
                sed -i \
                    -e 's/^pid_file/#pid_file/' \
                    -e '/^music_directory/s/".*"/"\/media"/' \
                    -e '/^bind_to_address/s/localhost/any/' \
                    -e "s/^#port/port/;/^port/s/\"[0-9]\+\"$/\"$MPD_PORT_CONTAINER\"/" \
                    -e '/^audio_output/,/^}/ s/^/#/' \
                    mpd.conf
                AddMPDSettings >> mpd.conf
                echo
            	echo "MPD configuration file initialized: mpd.conf"
            	echo "You can add audio device settings."
            else
                echo "removing old mpd image : $oldmpdimage"
                sudo docker rmi -f $oldmpdimage > /dev/null
            fi
        fi
        ;;
    "clean")
        sudo docker rmi radio_relay-build
        ;;
    "start")
        sudo -E docker-compose up -d
        ;;
    "stop")
        sudo -E docker-compose stop
        ;;
    "restart")
        sudo -E docker-compose restart
        ;;
    "down")
        sudo -E docker-compose down
        ;;
    "uninstall")
	sudo -E docker-compose down --rmi all --volumes --remove-orphans
	;;
    "build")
	    oldrrimage=$(sudo docker image ls -q $RR_IMAGE)
	    sudo -E docker-compose rm -s -f
            sudo -E docker-compose build
	    if [ -n "$oldrrimage" ]; then
	        echo "removing old image : $oldrrimage"
                sudo docker rmi -f $oldrrimage > /dev/null
	    fi
            ;;
    *)
        echo
        echo "$0 setup | start | stop | restart | down | clean | uninstall"
        echo
        echo "Force setup to rebuild webapp:"
        echo "$0 -f setup"
        echo
        ;;
esac

