#!/bin/bash

tput clear

url=https://maps.googleapis.com/maps/api/distancematrix/json
key="YOURKEY"
echo "This script calculates the distance and the transport duration between two places."
echo "Origin : "
read orig
orig_format=`echo $orig | tr ' ' '+'`
echo "Destination : "
read dest
dest_format=`echo $dest | tr ' ' '+'`
echo "Mode : (driving,walking,bicycling,transit)"
read mod

echo "Loading ..." | pv -qL 10

content=$(curl -s --get ''{$url}'' --data 'origins='{$orig_format}'&destinations='{$dest_format}'&mode='{$mod}'&language=en&key={$key}') 
echo $content > json

echo "Distance : "
dist=$(jq '.rows[0].elements[0].distance.text' json)
echo $dist
echo "Duration : "
tim=$(jq '.rows[0].elements[0].duration.text' json)
echo $tim

rm json
