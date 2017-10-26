#!/bin/bash

user=$(whoami)
pkthistory_file="/home/$user/tmp/zhone_pkthistory.txt"

column=2
intf="fib"

if [[ $# -ne 0 ]] ; then
   echo "Set column number to $1"
   column=$1
fi

cat $pkthistory_file | tr -s ' ' | sort -r -k $column | grep -i $intf | head -n 10
