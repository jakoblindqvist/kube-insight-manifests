#!/bin/bash

# docker requires absolute path to config
if [ -z $1 ] ; then
    echo "usage: prom-to-kairosdb.sh <config>"
    exit 1
fi
CONFIG=`pwd`"/"$1
echo "Using config file:" $CONFIG

# run prom-to-kairosdb
sudo docker run -p 9201:9201 --net=host -v $CONFIG:/etc/prometheus-kairosdb-adapter/config.yml proofpoint/prom-to-kairosdb:0.0.3 --config=/etc/prometheus-kairosdb-adapter/config.yml
