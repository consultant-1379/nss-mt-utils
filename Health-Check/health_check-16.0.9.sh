#!/bin/bash

rm -rf /netsim/netsimdir/ReadMe.txt
rm -rf /netsim/netsimdir/res.txt
echo "**********Hardware Check List**********">>/netsim/netsimdir/ReadMe.txt
chmod 777 /netsim/netsimdir/ReadMe.txt
#Ram=`awk '( $1 == "MemTotal:" ) { print $2/1048576 }' /proc/meminfo` 
Ram=`hwinfo --memory  | grep -i 'memory size'`
MemFree=`awk '( $1 == "MemFree:" ) { print $2/1048576 }' /proc/meminfo`
echo "$Ram">>/netsim/netsimdir/ReadMe.txt
echo "Free Memory is            :$MemFree">>/netsim/netsimdir/ReadMe.txt
noproc=`nproc`
echo "No.of CPU          :$noproc">>/netsim/netsimdir/ReadMe.txt
Ch=`cat /sys/block/sda/queue/scheduler`
Ch2=`cat /sys/block/sda/queue/nr_requests`
SCh=`echo $Ch | sed -e 's/^ *//g;s/ *$//g'`

if [ "$SCh" == "[noop] deadline cfq" ]
then
echo "Valid Kernel patch">>/netsim/netsimdir/ReadMe.txt
else
echo "Kernal Patch mis match">>/netsim/netsimdir/ReadMe.txt
fi
if [ "$Ch2" -eq 512 ]
then
echo "Valid Kernal patch">>/netsim/netsimdir/ReadMe.txt
else
echo "Kernal Patch mis match">>/netsim/netsimdir/ReadMe.txt
fi

echo "Kernal Patch              :$Ch            :$Ch2">>/netsim/netsimdir/ReadMe.txt
BWD=`/netsim_users/pms/bin/limitbw -n -s`
BWD1=`echo $BWD|grep -o NODE`
if [ -z "$BWD" ]
then
      echo "BWD is fine">>/netsim/netsimdir/ReadMe.txt
elif [ $BWD1 == "NODE" ]
then
    echo "BWD is fine">>/netsim/netsimdir/ReadMe.txt
else
    echo "BWD ISSUE">>/netsim/netsimdir/ReadMe.txt
fi 


#echo "Root User Crontab Info">>/netsim/netsimdir/ReadMe.txt
echo "**********Root User Crontab Details**********"
#crontab -l>>/netsim/netsimdir/ReadMe.txt
echo "**********End of Root User Crontab Details**********"
Days=`uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2 }'`
echo "Uptime in Days        =$Days">>/netsim/netsimdir/ReadMe.txt

