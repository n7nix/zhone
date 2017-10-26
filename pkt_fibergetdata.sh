#!/bin/bash
#
# Simpler version of pkt_getstats.sh
# - used for debugging graphs
# Uncomment this statement for debug echos
#DEBUG=1

login=
passwd=
ipaddr=
tmpfile_p="/tmp/zhonegraph_prev.txt"
zhone_cfgfile="/etc/zhone.conf"

# Zhone counters are only 32 bit numbers
POWER2to32=4294967296

# Read configuration file for login credentials & ip address
login=$(grep "LOGIN" $zhone_cfgfile | cut -d"=" -f2)
passwd=$(grep "PASSWORD" $zhone_cfgfile | cut -d"=" -f2)
ipaddr=$(grep "IP_ADDRESS" $zhone_cfgfile | cut -d"=" -f2)

statbuf=$(elinks -dump 1 http://$login:$passwd@$ipaddr/statsifc.html)

        ind=15
        intf="Fib"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
#        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d
	       # %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

#        env LC_ALL=en_US.UTF-8 printf "%13d  %13d\n" $if_rxb $if_txb



if [ ! -f $tmpfile_p ] ; then
   echo "0 0" > $tmpfile_p
   last_rxb=$if_rxb
   last_txb=$if_txb
else
   lastdata=$(cat $tmpfile_p)
   last_rxb=$(echo $lastdata | cut -d' ' -f1)
   last_txb=$(echo $lastdata | cut -d' ' -f2)
fi

# Init lastdata
echo "$if_rxb $if_txb" > $tmpfile_p

diff_rxb=$((if_rxb-last_rxb))
if (( diff_rxb < 0 )) ; then
   diff_rxb=$(( POWER2to32 + diff_rxb ))
fi

diff_txb=$((if_txb-last_txb))
if (( diff_txb < 0 )) ; then
   diff_txb=$(( POWER2to32 + diff_txb ))
fi

if [ ! -z "$DEBUG" ] ; then
   echo "val: $if_rxb $if_txb"
   echo "dif: $diff_rxb $diff_txb"
else
   echo "$diff_rxb $diff_txb"
fi


