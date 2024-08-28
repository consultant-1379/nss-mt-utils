#!/bin/bash
ls -1 /netsim/netsimdir/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E default >>SimList.txt
C=0;
sum=0;
while read line; 
do SimCount[$C]=$line;
    C=$(( C+1 ));
done <SimList.txt

for ((SimL=0;SimL<$C;SimL++));
do

MOMMLFILE="mocount.mml"
SIMNAME=${SimCount[$SimL]}
echo '.open '$SIMNAME > $MOMMLFILE
echo "opening Simulation $SIMNAME"
echo '.selectnocallback network' >> $MOMMLFILE
echo 'dumpmotree:count;'>>$MOMMLFILE
/netsim/inst/netsim_shell < $MOMMLFILE >> mocount.txt
cat mocount.txt |sed -e '1,5d' |sed 's/[^ ]* //' | sed '/^$/d' >>mocount1.txt
var=mocount1.txt
i=0;
while read line; 
do v[$i]=$line;
    i=$(( i+1 ));
done <$var

for (( j=0;j<$i;j++));
do
case "${v[$j]}" in
    "not found: dumpmotree")echo "not matched">/dev/null;;
    "Not started!")echo "not matched">/dev/null;;
        *)
    n=`echo ${v[$j]}`
  sum=`expr $sum + $n`
esac
done
rm -rf mocount.mml mocount.txt mocount1.txt SimList.txt
done
echo "sum of mocount     :$sum ">> /netsim/netsimdir/ReadMe.txt
