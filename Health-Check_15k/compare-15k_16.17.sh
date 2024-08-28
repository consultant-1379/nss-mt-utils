#!/bin/bash

rm -rf /netsim/netsimdir/res.txt
rm -rf SIML1.txt SIML2.txt Cron1.txt Cron2.txt celltrace1.txt celltrace2.txt LoadRead.txt LoadRef.txt Pread.txt Pref.txt

RAM=`cat /netsim/netsimdir/ReadMe.txt|grep "Memory Size"|cut -d ":" -f 2|cut -d " " -f 2|grep -v GB`

if [ $RAM -ge 64 ]
then
    echo "The RAM Size is sufficiently available:$RAM">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB - The RAM Available is Insufficient to run this job:$RAM">>/netsim/netsimdir/res.txt
fi

FreeMem=`cat /netsim/netsimdir/ReadMe.txt|grep "Free Memory is"|cut -d ":" -f 2`
FreeM=${FreeMem%%.*}


if [ $FreeM -ge 4 ]
then
    echo "The Free Size is sufficiently available:$FreeM">>/netsim/netsimdir/res.txt
else
    echo "The Free Memory Available is Insufficient to run this job:$FreeM">>/netsim/netsimdir/res.txt
fi

CPU1=`cat /netsim/netsimdir/ReadMe.txt|grep "No.of CPU"|cut -d ":" -f 2`
CPU2=`cat $1|grep "No.of CPU"|cut -d ":" -f 2`
if [ $CPU1 -ge $CPU2 ]
then
    echo "There is optimam availability of the CPU:$CPU1">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB - There is insufficient CPU availability to run this job:$CPU1">>/netsim/netsimdir/res.txt
fi

cat /netsim/netsimdir/ReadMe.txt | grep -A1 ">> .show numstartednes"|grep -v ">> .show numstartednes">>NES1
cat $1 | grep -A1 ">> .show numstartednes"|grep -v ">> .show numstartednes">>NES2
STNE=`cat NES1`

if (cmp -s NES1 NES2) 
then
    echo "The Number of Started Nodes is optimum:$STNE">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -There are less number of started nodes than required:$STNE
         [Suggestion]:Could you please start all the stopped nodes.">>/netsim/netsimdir/res.txt
fi

rm -rf NES1
rm -rf NES2

Days=`cat /netsim/netsimdir/ReadMe.txt|grep "Uptime in Days"|cut -d "=" -f 2`

case $Days in
    *:*)echo "Uptime is fine">>/netsim/netsimdir/res.txt;;
    *)
	if [ $Days -ge 10 ]
	then
	    echo "FAILEDJOB - Uptime is more than 10day pls reboot the machine:Days=$Days
[Suggestion]:Please reboot the netsim server using reboot command. All the nodes would be started once there is a reboot ">>/netsim/netsimdir/res.txt
	else
	    echo "Uptime is fine">>/netsim/netsimdir/res.txt
	fi
	;;
esac

if [ $2 == "Yes" ]
then
    yangRef=$1
case $yangRef in
    "Ref_15k_16.17.9.txt")
	if grep -w "No YANG Support" /netsim/netsimdir/ReadMe.txt; then
	    echo "FAILEDJOB:No YANG Support on this MT Deployment">>/netsim/netsimdir/res.txt
	else 
	    echo "******YANG Support ******Available on this MT deployment">>/netsim/netsimdir/res.txt
	    
	fi
	;;
    *);;
esac
else
    yangRef=$1
case $yangRef in
    "Ref_15k_16.17.9.txt")
	if grep -w "No YANG Support" /netsim/netsimdir/ReadMe.txt; then
	    echo "No YANG Support on this tribe deployment">>/netsim/netsimdir/res.txt
	else 
	    echo "#######YANG Support###### Available on this tribe deployment">>/netsim/netsimdir/res.txt
	    
	fi
	;;
    *);;
esac
    
fi



if grep -w "BWD ISSUE" /netsim/netsimdir/ReadMe.txt; then
  echo "FAILEDJOB:BWD ISSUE">>/netsim/netsimdir/res.txt
else 
  echo "BWD is fine">>/netsim/netsimdir/res.txt
fi

if grep -w "Kernal Patch mis match" /netsim/netsimdir/ReadMe.txt; then
  echo "FAILEDJOB:Kernal Patch mis match">>/netsim/netsimdir/res.txt
else 
  echo "Kernal Patch fine">>/netsim/netsimdir/res.txt
fi


PMStat1=`cat /netsim/netsimdir/ReadMe.txt|grep "PM data status" |cut -d ":" -f 2`
PMStat2=`cat $1|grep "PM data status"|cut -d ":" -f 2`

if [ $PMStat1 -eq $PMStat2 ]
then
    echo "PM Status is optimum:$PMStat1">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -PM Status is not as per the requirements:$PMStat1">>/netsim/netsimdir/res.txt
fi

Mainproc () {
echo "Received Values ******************$1,$2,$3,$4,$5"

if [ $3 -ge $4 ]
then
        MP=`grep -F -x -v -f $2 $1`
        if [  -z "$MP" ]; then
			MP2=`grep -F -x -v -f $1 $2`
			if [  -z "$MP2" ]; then
			echo "$5 are same ">>/netsim/netsimdir/res.txt
			else 
			echo "FAILEDJOB $5 discrepancy :$MP2">>/netsim/netsimdir/res.txt
			fi
          else 
	    echo "FAILEDJOB $5  discrepancy :$MP">>/netsim/netsimdir/res.txt
	fi
	
elif [ $4 -ge $3 ]
        then
        M=`grep -F -x -v -f $1 $2 `
        if [  -z "$M" ]; then
		   M2=`grep -F -x -v -f $2 $1 `
        if [  -z "$M2" ]; then
		   echo "$5(s) are same">>/netsim/netsimdir/res.txt
        else
            echo "FAILEDJOB $5  discrepancy  $M2">>/netsim/netsimdir/res.txt
	    fi
        else
         echo "FAILEDJOB $5  discrepancy   $M">>/netsim/netsimdir/res.txt
	 fi
         fi
}
sed -n '/Available Simulations/,/Total number of Simulations/p' /netsim/netsimdir/ReadMe.txt| grep -v "Available Simulations"|grep -v "Total number">>SIML1.txt
sed -n '/Available Simulations/,/Total number of Simulations/p' $1| grep -v "Available Simulations"|grep -v "Total number">>SIML2.txt
SIMCOUNT1=`cat SIML1.txt|wc -l`
SIMCOUNT2=`cat SIML2.txt|wc -l`
Header="SIM"
Mainproc SIML1.txt SIML2.txt $SIMCOUNT1 $SIMCOUNT2 $Header
sleep 5

sed -n /crontab.c,v/,//p /netsim/netsimdir/ReadMe.txt|grep -v Cron>>Cron1.txt
sed -n /crontab.c,v/,//p  $1|grep -v Cron>>Cron2.txt
Crc1=`cat Cron1.txt|wc -l`
Crc2=`cat Cron2.txt|wc -l`
Header="Cron"
Mainproc Cron1.txt Cron2.txt $Crc1 $Crc2 $Header
sleep 5

sed -n '/Celltrace and UETRACE file generation/,/CellTrace for MMEs/p' /netsim/$1 | sed 's/#//g' >>celltrace1.txt
sed -n '/Celltrace and UETRACE file generation/,/CellTrace for MMEs/p' /netsim/netsimdir/ReadMe.txt | sed 's/#//g' >>celltrace2.txt 
Trc1=`cat celltrace1.txt|wc -l`
Trc2=`cat celltrace2.txt|wc -l`
Header="UETRACE"
Mainproc celltrace1.txt celltrace2.txt $Trc1 $Trc2 $Header
sleep 5

Simcount1=`cat /netsim/netsimdir/ReadMe.txt | grep "Total number of Simulations"|cut -d ":" -f 2`
Simcount2=`cat $1 | grep "Total number of Simulations"|cut -d ":" -f 2`

if [ "$Simcount1" ==  "$Simcount2" ]
then
    echo "Simulation count is appropriate:$Simcount1">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB Mismatch in the simulation count:$Simcount1
[Suggestion]: Could you please cross check with the PRI">>/netsim/netsimdir/res.txt
fi

Version1=`cat /netsim/netsimdir/ReadMe.txt|grep "Netsim Current"|cut -d "*" -f 2`
Version2=`cat $1|grep "Netsim Current"|cut -d "*" -f 2`

if [ "$Version1" == "$Version2" ]
then
    echo "The NETSim Version is Valid:$Version1">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -Invalid NETSim Version:$Version1
   [Suggestion]: Could you please cross check with the PRI">>/netsim/netsimdir/res.txt
fi

cat /netsim/netsimdir/ReadMe.txt|grep "Node level load configuration" >>LoadRead.txt
cat /netsim/$1|grep "Node level load configuration">>LoadRef.txt
LDR=`cat LoadRead.txt|wc -l`
LDRF=`cat LoadRef.txt|wc -l`
Header="LOADB"
Mainproc LoadRead.txt LoadRef.txt $LDR $LDRF $Header
sleep 5

cat /netsim/netsimdir/ReadMe.txt|grep ^[P][0-9]*[_][UMTS]>Pread.txt
cat $1|grep ^[P][0-9]*[_][UMTS]>Pref.txt
RedMeCount=`cat Pread.txt | awk '{print $1}' |wc -l`
RefCount=`cat Pref.txt | awk '{print $1}' |wc -l`
Header="PATCH"
Mainproc Pread.txt Pref.txt $RedMeCount $RefCount $Header
sleep 5

echo -e "\n"
echo "##################Job Result##################################"
echo "Health Check script output"
cat /netsim/netsimdir/res.txt
echo -e "\n"
echo "############End of the Job with Result##########################"
rm -rf /netsim/health_check-15k_16.17.sh
rm -rf /netsim/netsim_checklist-15k_16.17.sh
rm -rf /netsim/compare-15k_16.17.sh
rm -rf /netsim/Mocnt-15k_16.17.sh
rm -rf SIML1.txt SIML2.txt Cron1.txt Cron2.txt celltrace1.txt celltrace2.txt LoadRead.txt LoadRef.txt Pread.txt Pref.txt
