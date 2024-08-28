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
#        /usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Checknew/health_install-1.0.1.sh
        Install=health_install-1.0.1.sh;;
    "16.5-1.0.2")
#        /usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Checknew/health_install-1.0.2.sh
        Install=health_install-1.0.2.sh;;
    "16.7")
#        /usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Checknew/health_install-1.0.3.sh
        Install=health_install-1.0.3.sh;;
    "16.5-1.0.3")
#        /usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Checknew/health_install-1.0.4.sh
        Install=health_install-1.0.4.sh;;
    "16.8")
#        /usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Checknew/health_install-16.0.8.sh
        Install=health_install-16.0.8.sh;;
    *)
        echo "Invalid Catalog. Please provide latest Catalog version"
        exit 1
;;
esac

TestResult=`sh $Install $Ip $Server $Ref`
exitCode=`echo $TestResult|grep -o FexitCodeILEDJOB|wc -l`> /dev/null
if [ $exitCode -eq 0 ]; then
    echo "SUCCESS"
else
    exit 1
fi
