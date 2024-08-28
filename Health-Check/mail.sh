#!/bin/bash -xe

#/usr/bin/curl -O  ftp://ftp.lmera.ericsson.se/project/netsim-ftp/scripts/Health-Check/Ref.txt


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

spawn scp -o StrictHostKeyChecking=no -P $PORT root@$Server.athtem.eei.ericsson.se:/netsim/netsimdir/res.txt .

expect {
 -re Password: {send "shroot\r";}
}
sleep 5
EOF




/usr/bin/expect  << EOF

set timeout -1

spawn scp -o StrictHostKeyChecking=no -p $PORT /root/res.txt 

expect {
  -re assword: {send "shroot\r";exp_continue}
     timeout {send "Timeout\n"}
      eof {exit}
       }
sleep 5
EOF
