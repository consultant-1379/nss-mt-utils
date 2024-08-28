#!/bin/bash -xe

rm -rf /netsim/netsimdir/res.txt
rm -rf SIML1.txt SIML2.txt Cron1.txt Cron2.txt celltrace1.txt celltrace2.txt LoadRead.txt LoadRef.txt Pread.txt Pref.txt

RAM=`cat /netsim/netsimdir/ReadMe.txt|grep "Memory Size"|cut -d ":" -f 2|cut -d " " -f 2|grep -v GB`

if [ $RAM -ge 96 ]
then
    echo "The RAM Size is sufficiently available">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB - The RAM Available is Insufficient to run this job">>/netsim/netsimdir/res.txt
fi

FreeMem=`cat /netsim/netsimdir/ReadMe.txt|grep "Free Memory is"|cut -d ":" -f 2`
FreeM=${FreeMem%%.*}


if [ $FreeM -ge 30 ]
then
    echo "The Free Size is sufficiently available">>/netsim/netsimdir/res.txt
else
    echo "The Free Memory Available is Insufficient to run this job">>/netsim/netsimdir/res.txt
fi

CPU1=`cat /netsim/netsimdir/ReadMe.txt|grep "No.of CPU"|cut -d ":" -f 2`
CPU2=`cat Ref_$1.txt|grep "No.of CPU"|cut -d ":" -f 2`
if [ $CPU1 -ge $CPU2 ]
then
    echo "There is optimam availability of the CPU">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB - There is insufficient CPU availability to run this job">>/netsim/netsimdir/res.txt
fi



cat /netsim/netsimdir/ReadMe.txt | grep -A1 ">> .show numstartednes"|grep -v ">> .show numstartednes">>NES1
cat Ref_$1.txt | grep -A1 ">> .show numstartednes"|grep -v ">> .show numstartednes">>NES2

if (cmp -s NES1 NES2) 
then
    echo "The Number of Started Nodes is optimum">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -There are less number of started nodes than required">>/netsim/netsimdir/res.txt
fi

rm -rf NES1
rm -rf NES2

Days=`cat /netsim/netsimdir/ReadMe.txt|grep "Uptime in Days"|cut -d "=" -f 2`

case $Days in
    *:*)echo "Uptime is fine">>/netsim/netsimdir/res.txt;;
    *)
	if [ $Days -ge 10 ]
	then
	    echo "FAILEDJOB - Uptime is more than 10day pls reboot the machine">>/netsim/netsimdir/res.txt
	else
	    echo "Uptime is fine">>/netsim/netsimdir/res.txt
	fi
	;;
esac



if grep -w "No YANG Support" /netsim/netsimdir/ReadMe.txt; then
  echo "FAILEDJOB:No YANG Support">>/netsim/netsimdir/res.txt
else 
  echo "YANG Support Available">>/netsim/netsimdir/res.txt
    
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
PMStat2=`cat Ref_$1.txt|grep "PM data status"|cut -d ":" -f 2`

if [ $PMStat1 -eq $PMStat2 ]
then
    echo "PM Status is optimum">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -PM Status is not as per the requirements">>/netsim/netsimdir/res.txt
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
sed -n '/Available Simulations/,/Total number of Simulations/p' Ref_$1.txt| grep -v "Available Simulations"|grep -v "Total number">>SIML2.txt
SIMCOUNT1=`cat SIML1.txt|wc -l`
SIMCOUNT2=`cat SIML2.txt|wc -l`
Header="SIM"
Mainproc SIML1.txt SIML2.txt $SIMCOUNT1 $SIMCOUNT2 $Header
sleep 5


sed -n /crontab.c,v/,//p /netsim/netsimdir/ReadMe.txt|grep -v Cron>>Cron1.txt
sed -n /crontab.c,v/,//p  Ref_$1.txt|grep -v Cron>>Cron2.txt
Crc1=`cat Cron1.txt|wc -l`
Crc2=`cat Cron2.txt|wc -l`
Header="Cron"
Mainproc Cron1.txt Cron2.txt $Crc1 $Crc2 $Header
sleep 5

sed -n '/Celltrace and UETRACE file generation/,/CellTrace for MMEs/p' /netsim/Ref_$1.txt >>celltrace1.txt
sed -n '/Celltrace and UETRACE file generation/,/CellTrace for MMEs/p' /netsim/netsimdir/ReadMe.txt >>celltrace2.txt 
Trc1=`cat celltrace1.txt|wc -l`
Trc2=`cat celltrace2.txt|wc -l`
Header="UETRACE"
Mainproc celltrace1.txt celltrace2.txt $Trc1 $Trc2 $Header
sleep 5





Simcount1=`cat /netsim/netsimdir/ReadMe.txt | grep "Total number of Simulations"|cut -d ":" -f 2`
Simcount2=`cat Ref_$1.txt | grep "Total number of Simulations"|cut -d ":" -f 2`

if [ "$Simcount1" ==  "$Simcount2" ]
then
    echo "Simulation count is appropriate">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB Mismatch in the simulation count">>/netsim/netsimdir/res.txt
fi

Version1=`cat /netsim/netsimdir/ReadMe.txt|grep "Netsim Current"|cut -d "*" -f 2`
Version2=`cat Ref_$1.txt|grep "Netsim Current"|cut -d "*" -f 2`

if [ "$Version1" == "$Version2" ]
then
    echo "The NETSim Version is Valid">>/netsim/netsimdir/res.txt
else
    echo "FAILEDJOB -Invalid NETSim Version">>/netsim/netsimdir/res.txt
fi


cat /netsim/netsimdir/ReadMe.txt|grep "Node level load configuration" >>LoadRead.txt
cat /netsim/Ref_$1.txt|grep "Node level load configuration">>LoadRef.txt
LDR=`cat LoadRead.txt|wc -l`
LDRF=`cat LoadRef.txt|wc -l`
Header="LOADB"
Mainproc LoadRead.txt LoadRef.txt $LDR $LDRF $Header
sleep 5




cat /netsim/netsimdir/ReadMe.txt|grep ^[P][0-9]*[_][UMTS]>Pread.txt
cat Ref_$1.txt|grep ^[P][0-9]*[_][UMTS]>Pref.txt
RedMeCount=`cat Pread.txt | awk '{print $1}' |wc -l`
RefCount=`cat Pref.txt | awk '{print $1}' |wc -l`
Header="PATCH"
Mainproc Pread.txt Pref.txt $RedMeCount $RefCount $Header
sleep 5




echo -e "\n"
echo "**********Job Result**********"

cat /netsim/netsimdir/res.txt
echo -e "\n"
echo "**********End of the Job with Result**********"
rm -rf /netsim/health_check.sh
rm -rf /netsim/netsim_checklist.sh
rm -rf /netsim/compare.sh
rm -rf /netsim/Mocnt.sh
rm -rf SIML1.txt SIML2.txt Cron1.txt Cron2.txt celltrace1.txt celltrace2.txt LoadRead.txt LoadRef.txt Pread.txt Pref.txt




