#!/bin/bash -xe

#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/script.sh
#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/health_check.sh
#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/netsim_checklist.sh
#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/compare.sh
#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/Mocnt.sh
#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/Ref_$Catalog.txt


if [ ! -n "$Catalog" ] ; then
        echo "Invalid Catalog. Please provide latest Catalog version"
         exit 1
fi 

if [[ "$Server" =~ "ieat" ]]
#if [ $Server|grep -o ieat==ieat ]
then
PORT=22
elif [[ "$Server" =~ "netsimlin" ]]
then
PORT=22
else
PORT=2202
fi

/usr/bin/expect  << EOF

spawn ssh -o StrictHostKeyChecking=no -p 2202 root@141.137.234.34 

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT $WORKSPACE/script.sh $WORKSPACE/health_check.sh $WORKSPACE/netsim_checklist.sh $WORKSPACE/compare.sh $WORKSPACE/Mocnt.sh $WORKSPACE/Ref_$Catalog.txt root@$Server.athtem.eei.ericsson.se:/netsim/

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT root@$Server.athtem.eei.ericsson.se sh /netsim/health_check.sh

expect {
  -re assword: {send "shroot\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT netsim@$Server.athtem.eei.ericsson.se sh /netsim/netsim_checklist.sh $Catalog

expect {
  -re assword: {send "netsim\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF







