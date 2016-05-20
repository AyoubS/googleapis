#!/bin/bash

#Set these to abort whenever a command exits with a code different than 0
# set -e
# set -o pipefail
#
# tput clear

usage="$(basename "$0") [-h] [-z n] -- program that shows the location of a place on the map

where:
    -h  show this help text
    -z  set the zoom according to your query : preferably 5 for a country, 10 for a city (default: 5)"

zoom=5
while getopts ':hz:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    z) zoom=$OPTARG
        url=https://maps.google.com/maps/api/geocode/json
        data=$1+$2+$3+$4+$5+$6
        key="YOURKEY"
        content=$(curl -s --get ''{$url}'' --data 'address='{$data}'&sensor=false&key={$key}') 
        echo $content > json

        # check if jq is installed
        test=`dpkg -s jq | grep installed | cut -d" " -f4`
        
        if [ "$test" != "installed" ]
         then echo "Installing jq - Command-line JSON processor..."
         apt-get install jq
        fi

        list=(lat lng)
        for item in ${list[*]}
        do
          json=$(jq '.results[0].geometry.location.'${item}'' json)
          echo $json >> output
        done

        echo "Latitude : "
        a=`sed -n 1p output`
        echo $a
        echo "Longitude : "
        b=`sed -n 2p output`
        echo $b

        curl -s --get 'https://maps.googleapis.com/maps/api/staticmap' --data 'center='$data'&zoom='$zoom'&format=jpg&sensor=false&size=640x640&scale=2&maptype=satellite&key=$key' -o map.jpg 
        
        # Optional: open the downloaded image with your favorite image viewer
        ristretto map.jpg &

        rm json output
        exit 1
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
unset zoom
if [ -z "$zoom" ]; then
  echo "$usage" >&2
fi
shift $((OPTIND - 1))
