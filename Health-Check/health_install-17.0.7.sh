#!/bin/bash

echo " $Release"

MTCheck=$4

Server=$2
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

spawn ssh -o StrictHostKeyChecking=no -p 22 root@$1

expect {
 -re Password: {send "12shroot\r";}
}
sleep 5
EOF
/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT $WORKSPACE/health_check-17.0.6.sh $WORKSPACE/netsim_checklist-17.0.6.sh $WORKSPACE/compare-17.0.6.sh $WORKSPACE/Mocnt-17.0.6.sh $WORKSPACE/Ref_17.6.1.txt root@$1:/root/

expect {
 -re Password: {send "12shroot\r";}
}
sleep 15
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT health_check-17.0.6.sh netsim_checklist-17.0.6.sh compare-17.0.6.sh Mocnt-17.0.6.sh Ref_17.6.1.txt root@$Server.athtem.eei.ericsson.se:/netsim/

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT root@$Server.athtem.eei.ericsson.se sh /netsim/health_check-17.0.6.sh

expect {
  -re assword: {send "shroot\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT netsim@$Server.athtem.eei.ericsson.se sh /netsim/netsim_checklist-17.0.6.sh Ref_17.6.1.txt $MTCheck

expect {
  -re assword: {send "netsim\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF
