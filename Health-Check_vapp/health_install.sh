#!/bin/bash -xe

if [ ! -n "$Catalog" ] ; then
        echo "Invalid Catalog. Please provide latest Catalog version"
        exit 1
fi 
if [[ "$Server" =~ "ieat" ]]
then
PORT=22
elif [[ "$Server" =~ "netsimlin" ]]
then
PORT=22
else
PORT=2202
fi
/usr/bin/expect  << EOF

spawn ssh -o StrictHostKeyChecking=no -p 2202 root@$Server.athtem.eei.ericsson.se 

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT $WORKSPACE/script.sh $WORKSPACE/health_check.sh $WORKSPACE/netsim_checklist.sh $WORKSPACE/compare.sh $WORKSPACE/Mocnt.sh $WORKSPACE/Ref_$Catalog.txt root@$Server.athtem.eei.ericsson.se:/root/

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT script.sh health_check.sh netsim_checklist.sh compare.sh Mocnt.sh Ref_$Catalog.txt $Release.txt root@$Server.athtem.eei.ericsson.se:/netsim/

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
