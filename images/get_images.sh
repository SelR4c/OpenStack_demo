#!/bin/bash -e

URLS="http://cdimage.debian.org/cdimage/openstack/current/debian-9.8.2-20190303-openstack-amd64.qcow2"

for URL in $URLS
do
FILENAME=${URL##*/}
if [ -r $FILENAME ];
then
    echo "$FILENAME already downloaded." 
else
    wget  -O  $FILENAME $URL
fi
done

mv debian* debian.qcow2
