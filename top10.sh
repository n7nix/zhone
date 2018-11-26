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
pktlastmonth_file="/home/$user/tmp/zhone_pktlastmonth.txt"
pkthistory_sortfile="/home/$user/tmp/zhone_sortpkthistory.txt"
intface_names="Fib GE1 GE2 GE3 GE4"

# ===== function usage
function usage() {
   echo "Usage: $scriptname [-c <column_number>] [-i <interface_name>] -n <display_lines>]"
   echo "   -c column_number (3-6)"
   echo "   -i interface name (Fib GE1 GE2 GE3 GE4)"
   echo "   -n display_lines  (integer > 0)"
}

# ===== function rank_all
function rank_all() {
    history_file="$1"
    # Find ranking of last packet count
    yesterdate=$(date --date="yesterday" "+%Y%m%d")
    rank=$(cat $history_file | tr -s ' ' | tr -d ',' | grep -i $intf | sort -rg -k $column | grep -n $yesterdate | cut -d: -f1)

    # Find total number of days worth of packet counts
    hist_cnt=$(cat $history_file | grep -i $intf | wc -l)

    echo "Rank: $rank out of $hist_cnt"
    echo
    cat $history_file | tr -s ' ' | tr -d ',' | grep -i $intf | sort -rg -k $column | head -n $display
}

# ===== create_month_file
function create_month_file() {
    cutdate="$1"
    rm $pktlastmonth_file
    while IFS= read -r line; do
	read -r x d <<< "$line"
	if (( $(echo $line | cut -d' ' -f1) >= $cutdate )); then
	    printf '%s\n' "$line" >> $pktlastmonth_file
	fi
    done < $pkthistory_file
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

# Get last packet count
yesterdate=$(date --date="yesterday" "+%Y%m%d")

value=$(cat $pkthistory_file | tr -s ' ' | grep -i $intf | grep -i $yesterdate | cut -d' ' -f3)
echo "pkt cnt: $value on $(date)"

# Collapse spaces & tabs
#sed -i -e "s/[[:space:]]\+/ /g" $pkthistory_file

rank_all $pkthistory_file

# Create history file for last month

cutdate=$(date -d "1 month ago" '+%Y%m%d')
create_month_file $cutdate
echo
rank_all $pktlastmonth_file
