#!/bin/bash
#
# Simpler version of pkt_getstats.sh
# - used to collect data forr rrd in:
#  db_pktstatsupdate.sh (GE1-4 interfaces)
#  db_fiberpktstatsupdate.sh (Fiber interface)
# Uncomment this statement for debug echos
#DEBUG=1

login=
passwd=
ipaddr=

MNTPNT="/media/backup/rrd/var/tmp/pktcnt"
MNTPNT="/tmp"
zhone_cfgfile="/etc/zhone.conf"

function dbgecho { if [ ! -z "$DEBUG" ] ; then echo "$*"; fi }

if [ ! -z "$DEBUG" ] ; then
   tmpfile_p="$MNTPNT/zhonegraph_prevtest.txt"
else
   tmpfile_p="$MNTPNT/zhonegraph_prev.txt"
fi

# Zhone counters are only 32 bit numbers
POWER2to32=4294967296

# declare associative arrays
# - interface names are keys
declare -A rxb=()
declare -A rxf=()
declare -A txb=()
declare -A txf=()
declare -A lastrxb=()
declare -A lasttxb=()
declare -A diffrxb=()
declare -A difftxb=()

# Read configuration file for login credentials & ip address
login=$(grep "LOGIN" $zhone_cfgfile | cut -d"=" -f2)
passwd=$(grep "PASSWORD" $zhone_cfgfile | cut -d"=" -f2)
ipaddr=$(grep "IP_ADDRESS" $zhone_cfgfile | cut -d"=" -f2)

# Read the stats from the Zhone html interface
statbuf=$(elinks -dump 1 http://$login:$passwd@$ipaddr/statsifc.html)

# Iterate through interfaces
ind=15
for intf in "fib" "ge1" "ge2" "ge3" "ge4" ; do

   rxb[$intf]=$(echo  $statbuf | cut -d '|' -f$ind)
   rxf[$intf]=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
   txb[$intf]=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
   txf[$intf]=$(echo  $statbuf | cut -d '|' -f$((ind+5)))

   ind=$((ind+=18))
done


if [ ! -f $tmpfile_p ] ; then
   dbgecho "file does NOT exist: $tmpfile_p"
#   intf="fib"
#   echo "0 0 0 0 0 0 0 0 0 0" > $tmpfile_p

   for intf in "fib" "ge1" "ge2" "ge3" "ge4" ; do
      lastrxb[$intf]=${rxb[$intf]}
      lasttxb[$intf]=${txb[$intf]}
   done
   dbgecho "debug: fib: ${lastrxb[fib]} ${lasttxb[fib]}"
else
   dbgecho "file exists: $tmpfile_p"
   lastdata=$(cat $tmpfile_p)

   ind=1
   for intf in "fib" "ge1" "ge2" "ge3" "ge4" ; do
      lastrxb[$intf]=$(echo  $lastdata | cut -d ' ' -f$ind)
      lasttxb[$intf]=$(echo  $lastdata | cut -d ' ' -f$((ind+1)))
      ind=$((ind+=2))

      dbgecho "lastrxb[$intf] = ${lastrxb[$intf]} lasttxb[$intf]=${lasttxb[$intf]}"

   done
   dbgecho "last: ${lastrxb[fib]} ${lasttxb[fib]}"
   dbgecho "last: ${lastrxb[ge1]} ${lasttxb[ge1]} ${lastrxb[ge2]} ${lasttxb[ge2]} ${lastrxb[ge3]} ${lasttxb[ge3]} ${lastrxb[ge4]} ${lasttxb[ge4]}"
fi

# Init lastdata
echo "${rxb[fib]} ${txb[fib]} ${rxb[ge1]} ${txb[ge1]} ${rxb[ge2]} ${txb[ge2]} ${rxb[ge3]} ${txb[ge3]} ${rxb[ge4]} ${txb[ge4]}" > $tmpfile_p

for intf in "fib" "ge1" "ge2" "ge3" "ge4" ; do

   diffrxb[$intf]=$((rxb[$intf]-lastrxb[$intf]))
   if (( diffrxb[$intf] < 0 )) ; then
      dbgecho "Roll over on rxb intf: $intf val: ${diffrxb[$intf]}"
      diffrxb[$intf]=$(( POWER2to32 + diffrxb[$intf] ))
   else
      dbgecho "rxb $intf: val: ${rxb[$intf]} last: ${lastrxb[$intf]}, diff: ${diffrxb[$intf]}"
   fi

   difftxb[$intf]=$((txb[$intf]-lasttxb[$intf]))
   if (( difftxb[$intf] < 0 )) ; then
      dbgecho "Roll over on txb intf: $intf val: ${difftxb[$intf]}"
      difftxb[$intf]=$(( POWER2to32 + difftxb[$intf] ))
   else
      dbgecho "txb $intf: val: ${txb[$intf]} last: ${lasttxb[$intf]}, diff: ${difftxb[$intf]}"
   fi
done

if [ ! -z "$DEBUG" ] ; then
   echo "val: ${rxb[fib]} ${txb[fib]} ${rxb[ge1]} ${txb[ge1]} ${rxb[ge2]} ${txb[ge2]} ${rxb[ge3]} ${txb[ge3]} ${rxb[ge4]} ${txb[ge4]}"
   echo "dif: ${diffrxb[fib]} ${difftxb[fib]} ${diffrxb[ge1]} ${difftxb[ge1]} ${diffrxb[ge2]} ${difftxb[ge2]} ${diffrxb[ge3]} ${difftxb[ge3]} ${diffrxb[ge4]} ${difftxb[ge4]}"
else
   echo "${diffrxb[fib]} ${difftxb[fib]} ${diffrxb[ge1]} ${difftxb[ge1]} ${diffrxb[ge2]} ${difftxb[ge2]} ${diffrxb[ge3]} ${difftxb[ge3]} ${diffrxb[ge4]} ${difftxb[ge4]}"
fi
