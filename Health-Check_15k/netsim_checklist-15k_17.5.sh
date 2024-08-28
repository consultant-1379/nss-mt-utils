#!/bin/bash
echo "**********NETSim Check List**********">>/netsim/netsimdir/ReadMe.txt
Netsim_Version=`cat ~/inst/release.erlang`
echo "Netsim Current Version            :$Netsim_Version">>/netsim/netsimdir/ReadMe.txt
echo -e "**********Patch List**********\n">>/netsim/netsimdir/ReadMe.txt

Installed_Patches=`echo ".show patch info" | /netsim/inst/netsim_shell`
echo "Installed Patches are             :$Installed_Patches">>/netsim/netsimdir/ReadMe.txt

Started_NES=`echo ".show numstartednes" | /netsim/inst/netsim_shell`
echo "Started_NES               :$Started_NES">>/netsim/netsimdir/ReadMe.txt
echo "**********Simulations Check List**********">>/netsim/netsimdir/ReadMe.txt
Sim_List=`ls -1 /netsim/netsimdir/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E default`
echo  "Available Simulations             :">>/netsim/netsimdir/ReadMe.txt
echo "$Sim_List">>/netsim/netsimdir/ReadMe.txt

Sim_Count=`ls -1 /netsim/netsimdir/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E default |wc -lw`
echo "Total number of Simulations are           :$Sim_Count">>/netsim/netsimdir/ReadMe.txt
for i in LTE0{1..6};
do
SIM=`ls /netsim/netsimdir/ |grep $i|grep -v "zip"`;
echo $SIM ;
echo -e ".select network \n pmdata:status;"|/netsim/inst/netsim_shell -sim $SIM;
done|grep disabled |echo "PM data status                :`wc -l`">>/netsim/netsimdir/ReadMe.txt

for i in LTE0{1..6};
do
SIM=`ls /netsim/netsimdir/ |grep $i|grep -v "zip"`;
echo $SIM ;
echo -e ".select network \n showscanners2;"|/netsim/inst/netsim_shell -sim $SIM;
done|grep "There are no scanners" |echo "PM Scanners                :`wc -l`">>/netsim/netsimdir/ReadMe.txt

LoadB=`echo ".show serverloadconfig" | /netsim/inst/netsim_shell`
echo "Load Balancing            :$LoadB">>/netsim/netsimdir/ReadMe.txt
sh Mocnt-1.0.1.sh

yangRef=$1
case $yangRef in
    "Ref_15k_17.4.9.txt")
    	echo -e "**********YANG Support Check**********\n">>/netsim/netsimdir/ReadMe.txt
	Yang=`cat /netsim/inst/config`
	if [ -z "$Yang" ]
	then
	    echo "No YANG Support">>/netsim/netsimdir/ReadMe.txt
	else
	    echo "YANG Support Available $Yang">>/netsim/netsimdir/ReadMe.txt
	fi 
	;;
    *);;
esac


echo -e "**********Genstats Information**********\n">>/netsim/netsimdir/ReadMe.txt

echo -e "####Netsim config file and Crontab related Information####\n">>/netsim/netsimdir/ReadMe.txt

cat /netsim/netsim_cfg>>/netsim/netsimdir/ReadMe.txt
echo ""
echo "**********User Crontab Details**********"
crontab -l >>/netsim/netsimdir/ReadMe.txt
echo "**********End of Uesr Crontab Details**********"
echo "**********Content of ReadMe.txt is **********"
cat /netsim/netsimdir/ReadMe.txt

sh compare-15k_17.5.sh $1 $2
