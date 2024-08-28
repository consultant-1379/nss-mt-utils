#!/bin/bash

case $3 in
    "Ref1")
	Release=Ref_16.14.1;;
    "Ref2")
	Release=Ref_16.14.2;;
    "Ref3")
	Release=Ref_16.14.3;;
    *)echo -e "Invalid Job Configuration"
	exit 1;;
esac

	echo "******************Release $Release"
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

spawn scp -o StrictHostKeyChecking=no -P $PORT $WORKSPACE/health_check-16.0.14.sh $WORKSPACE/netsim_checklist-16.0.14.sh $WORKSPACE/compare-16.0.14.sh $WORKSPACE/Mocnt-16.0.14.sh $WORKSPACE/$Release.txt root@$1:/root/

expect {
 -re Password: {send "12shroot\r";}
}
sleep 15
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT health_check-16.0.14.sh netsim_checklist-16.0.14.sh compare-16.0.14.sh Mocnt-16.0.14.sh $Release.txt root@$Server.athtem.eei.ericsson.se:/netsim/

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT root@$Server.athtem.eei.ericsson.se sh /netsim/health_check-16.0.14.sh

expect {
  -re assword: {send "shroot\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT netsim@$Server.athtem.eei.ericsson.se sh /netsim/netsim_checklist-16.0.14.sh $Release.txt $MTCheck

expect {
  -re assword: {send "netsim\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF
