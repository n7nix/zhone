#!/bin/bash
#
# Sort the zhone packet history file by column numerically
#
# ./top10.sh -c [column_number]
# Col  count
#  3    txb
#  4    txf
#  5    rxb
#  6    rxf
#
# Interface names Fib GE1 GE2 GE3 GE4

user=$(whoami)
pkthistory_file="/home/$user/tmp/zhone_pkthistory.txt"
pkthistory_sortfile="/home/$user/tmp/zhone_sortpkthistory.txt"
intface_names="Fib GE1 GE2 GE3 GE4"

# ===== function usage
function usage() {
   echo "Usage: $scriptname [-c <column_number>] [-i <interface_name>] -n <display_lines>]"
   echo "   -c column_number (3-6)"
   echo "   -i interface name (Fib GE1 GE2 GE3 GE4)"
   echo "   -n display_lines  (integer > 0)"
}

# ===== main

# set defaults
display=10
column=3
intf="fib"

while [[ $# -gt 0 ]] ; do
arg="$1"

case $arg in
# Column number 3 - 6
   -c)
      if (( "$2" > 6 )) ; then
         echo "There are only 6 columns."
         column=1
      else
         column="$2"
      fi
      shift # past argument
   ;;
   # interface name fib ge1-4
   -i)
      intf="$2"
      grep -i $intf <<< $intface_names > /dev/null 2>&1
      if [ ! $? -eq 0 ] ; then
         echo "Interface $intf invalid, most be one of $intface_names"
	 usage
	 exit 1
      fi
      shift # past argument
   ;;
   # number of lines to display
   -n)
      display="$2"
      shift # past argument
   ;;
   *)
      usage
      exit 0
   ;;

esac
shift # to next arg
done

echo "Sort on column number: $column, for interface: $intf, display top: $display"

# Collapse spaces & tabs
#sed -i -e "s/[[:space:]]\+/ /g" $pkthistory_file

# Find ranking of last packet count
yesterdate=$(date --date="yesterday" "+%Y%m%d")
rank=$(cat $pkthistory_file | tr -s ' ' | tr -d ',' | grep -i $intf | sort -rg -k $column | grep -n $yesterdate | cut -d: -f1)

# Find total number of days worth of packet counts
hist_cnt=$(cat $pkthistory_file | grep -i $intf | wc -l)

# Get last packet count
value=$(cat $pkthistory_file | tr -s ' ' | grep -i $intf | grep -i $yesterdate | cut -d' ' -f3)
# echo "Value: $value"

echo "Rank: $rank out of $hist_cnt, pkt cnt: $value"
echo
cat $pkthistory_file | tr -s ' ' | tr -d ',' | grep -i $intf | sort -rg -k $column | head -n $display
