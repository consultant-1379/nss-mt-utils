#!/bin/bash -xe

Catalog=$1
Server=$2
ClusterId=$3
Ref=$4

if [ ! -n "$Catalog" ]; then
    echo "Invalid Catalog. Please provide latest Catalog version"
    exit 1
fi

if [ ! -n "$Server" ]; then
    echo "Invalid Server. Please provide latest Server"
    exit 1
fi

if [ ! -n "$ClusterId" ]; then
    echo "Invalid Clusterid. Please provide latest Clusterid "
    exit 1
fi

if [ ! -n "$Ref" ]; then
    echo "Invalid Ref. Please provide latest Ref "
    exit 1
fi


Ip=`wget -q -O - --no-check-certificate "https://cifwk-oss.lmera.ericsson.se/generateTAFHostPropertiesJSON/?clusterId=$ClusterId&tunnel=true" | awk -F',' '{print $1}' | awk -F':' '{print $2}' | sed -e "s/\"//g" -e "s/ //g"`>/dev/null
echo "************$Ip"
echo "************$Server"
case $Catalog in
    "16.5-1.0.1")
        echo "Running: 16.5-1.0.1";;
    "16.5-1.0.2")
        echo "Running: 16.5-1.0.2";;
    "16.7")
        echo "Running: 16.7";;
    "16.5-1.0.3")
        echo "Running: 16.5-1.0.3";;
    "16.8")
        echo "Running: 16.8";;
    *)
        echo "Invalid Catalog. Please provide latest Catalog version"
        exit 1;;
esac

echo "SUCCESS"
