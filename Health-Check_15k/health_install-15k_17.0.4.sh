
#!/bin/bash

case $3 in
    "Ref1")
	Release=Ref_15k_17.4.1;;
    "Ref2")
	Release=Ref_15k_17.4.2;;
    "Ref3")
	Release=Ref_15k_17.4.3;;
    "Ref4")
	Release=Ref_15k_17.4.4;;
    "Ref5")
	Release=Ref_15k_17.4.5;;
    "Ref6")
	Release=Ref_15k_17.4.6;;
    "Ref7")
	Release=Ref_15k_17.4.7;;
    "Ref8")
	Release=Ref_15k_17.4.8;;
    "Ref9")
	Release=Ref_15k_17.4.9;;
    *)echo -e "Invalid Job Configuration"
	exit 1;;
esac
MTCheck=No
	echo "******************Release $Release"

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

spawn scp -o StrictHostKeyChecking=no -P $PORT $WORKSPACE/health_check-15k_17.4.sh $WORKSPACE/netsim_checklist-15k_17.4.sh $WORKSPACE/compare-15k_17.4.sh $WORKSPACE/Mocnt-15k_17.4.sh $WORKSPACE/$Release.txt root@$1:/root/

expect {
 -re Password: {send "12shroot\r";}
}
sleep 15
EOF

/usr/bin/expect  << EOF

spawn scp -o StrictHostKeyChecking=no -P $PORT health_check-15k_17.4.sh netsim_checklist-15k_17.4.sh compare-15k_17.4.sh Mocnt-15k_17.4.sh $Release.txt root@$Server.athtem.eei.ericsson.se:/netsim/

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT root@$Server.athtem.eei.ericsson.se sh /netsim/health_check-15k_17.4.sh

expect {
  -re assword: {send "shroot\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF

/usr/bin/expect  << EOF

set timeout -1

spawn ssh -o StrictHostKeyChecking=no -p $PORT netsim@$Server.athtem.eei.ericsson.se sh /netsim/netsim_checklist-15k_17.4.sh $Release.txt $MTCheck

expect {
  -re assword: {send "netsim\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF
