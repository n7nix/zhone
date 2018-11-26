#!/bin/bash
#
# Reset Zhone statistics counters at around midnight.
# Display when statistic counter roll over occurs.
#
# Send an email just past midnight of daily packet totals.

scriptname="`basename $0`"
user=$(whoami)

RESET_COUNTERS=y

# Zhone counters are only 32 bit numbers
POWER2to32=4294967296

# Zhone route login credentials
login=
passwd=
ipaddr=

# These all work but need to change cut cmd for each
# elinks -dump 1 http://$login:$passwd@$ipaddr/statsifc.html | grep -i "fiber"
# links2 -dump http://$login:$passwd@$ipaddr/statsifc.html | grep -i "fiber"
# lynx -dump -auth=$login:$passwd http://$ipaddr/statsifc.html | grep -i "fiber"

# declare associative arrays
# - interface names are keys
declare -A acc_rxb=()
declare -A acc_rxf=()
declare -A acc_txb=()
declare -A acc_txf=()

SYSOP_EMAIL="$user@$(hostname)"
email_file="/tmp/emailstats.txt"
history_file="/home/$user/tmp/zhone_pkthistory.txt"
zhone_cfgfile="/etc/zhone.conf"

totalfile_fib="/tmp/zhone_tFib.txt"
totalfile_ge1="/tmp/zhone_tGE1.txt"
totalfile_ge2="/tmp/zhone_tGE2.txt"
totalfile_ge3="/tmp/zhone_tGE3.txt"
totalfile_ge4="/tmp/zhone_tGE4.txt"

tmpfile=/tmp/zhone.txt
tmpfile_p=/tmp/zhone_prev.txt
KEEP_PREV="false"

# ==== function send_email
function send_email() {
   # Only send email if DEBUG not defined
   if [ -z "$DEBUG" ] ; then
      subject="$1"
      mutt -s "$subject" $SYSOP_EMAIL < "$2"
   else
      echo "Debug defined, not sending email"
      echo "email body: $2"
   fi
}

# ==== main

# Read configuration file for login credentials & ip address
login=$(grep "LOGIN" $zhone_cfgfile | cut -d"=" -f2)
passwd=$(grep "PASSWORD" $zhone_cfgfile | cut -d"=" -f2)
ipaddr=$(grep "IP_ADDRESS" $zhone_cfgfile | cut -d"=" -f2)

elinks -dump 1 http://$login:$passwd@$ipaddr/statsifc.html > $tmpfile

# Any command line args? Keep previous results.
# Used for testing
if [[ $# -gt 0 ]] ; then
   KEEP_PREV="true"
fi


# print a header
echo "                       R                           T"
echo "Iface:         bytes        frames         bytes        frames"

# Iterate through interfaces
for intf in "Fib" "GE1" "GE2" "GE3" "GE4"
do
   ifres=$(cat $tmpfile | grep -i "$intf")

   if_rxb=$(echo $ifres | cut -d'|' -f3)
   if_rxf=$(echo $ifres | cut -d'|' -f4)
   if_txb=$(echo $ifres | cut -d'|' -f7)
   if_txf=$(echo $ifres | cut -d'|' -f8)
   env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

   # Check zhone previous file exists
   if [ -f $tmpfile_p ] ; then
      # display difference in bytes & frames values
      ifdel=$(cat $tmpfile_p | grep -i "$intf")

      del_rxb=$(echo $ifdel | cut -d'|' -f3)
      del_rxf=$(echo $ifdel | cut -d'|' -f4)
      del_txb=$(echo $ifdel | cut -d'|' -f7)
      del_txf=$(echo $ifdel | cut -d'|' -f8)

      # detect 32 bit number roll over
      dif_rxb=$(( if_rxb - del_rxb ))
#      echo "debug "$intf: dif $dif_rxb, if $if_rxb, del $del_rxb
      if (( $dif_rxb < 0 )) ; then
         echo "Zhone stats counter rxb rollover $if_rxb $del_rxb $dif_rxb"
         dif_rxb=$(( POWER2to32 + dif_rxb ))
      fi

      dif_rxf=$(( if_rxf - del_rxf ))
#      echo "debug "$intf: dif $dif_rxf, if $if_rxf, del $del_rxf
      if (( $dif_rxf < 0 )) ; then
         echo "Zhone stats counter rxf rollover"
         dif_rxf=$(( POWER2to32 + dif_rxf ))
      fi

      dif_txb=$(( if_txb - del_txb ))
      if (( $dif_txb < 0 )) ; then
         echo "Zhone stats counter txb rollover"
         dif_txb=$(( POWER2to32 + dif_txb ))
      fi

      dif_txf=$(( if_txf - del_txf ))
      if (( $dif_txf < 0 )) ; then
         echo "Zhone stats counter txf rollover"
         dif_txf=$(( POWER2to32 + dif_txf ))
      fi

#      env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((del_rxb)) $((del_rxf)) $del_txb $del_txf
      env LC_ALL=en_US.UTF-8 printf "diff:\t  %'13d  %'10d   %'13d  %'10d\n" $dif_rxb $dif_rxf $dif_txb $dif_txf

      # Test if zhone packet count file exists
      if [ ! -f "/tmp/zhone_t$intf" ] ; then
         echo "$dif_rxb $dif_rxf $dif_txb $dif_txf" > /tmp/zhone_t$intf
	 acc_rxb=$dif_rxb
	 acc_rxf=$dif_rxf
	 acc_txb=$dif_txb
	 acc_txf=$dif_txf

      else
         acc_str=$(cat "/tmp/zhone_t$intf")
#	 echo "debug: str: $acc_str"
	 acc_rxb=$(echo $acc_str | cut -d ' ' -f1)
	 acc_rxf=$(echo $acc_str | cut -d ' ' -f2)
	 acc_txb=$(echo $acc_str | cut -d ' ' -f3)
	 acc_txf=$(echo $acc_str | cut -d ' ' -f4)
#	 echo "debug: acc: $acc_rxb $acc_rxf $acc_txb $acc_txf"
#	 echo "debug: dif: $dif_rxb $dif_rxf $dif_txb $dif_txf"
	 acc_rxb[$intf]=$((acc_rxb + dif_rxb))
	 acc_rxf[$intf]=$((acc_rxf + dif_rxf))
	 acc_txb[$intf]=$((acc_txb + dif_txb))
	 acc_txf[$intf]=$((acc_txf + dif_txf))
# 	 echo "debug: tot: $acc_rxb $acc_rxf $acc_txb $acc_txf"
         # Update accumulating totals
         echo "${acc_rxb[$intf]} ${acc_rxf[$intf]} ${acc_txb[$intf]} ${acc_txf[$intf]}" > /tmp/zhone_t$intf
      fi
      env LC_ALL=en_US.UTF-8 printf "acc:\t  %'13d  %'10d   %'13d  %'10d\n" ${acc_rxb[$intf]} ${acc_rxf[$intf]} ${acc_txb[$intf]} ${acc_txf[$intf]}
   fi
done

# Check keep previous results var
if [ "$KEEP_PREV" = "false" ] ; then
   mv $tmpfile $tmpfile_p
fi

echo "1: seconds since last hour: $(( $(date +%s) %3600 ))"

if [ "$RESET_COUNTERS" = "y" ] ; then
   # reset zhone counters at midnight to reduce rollover
   eval "$(date +'today=%F now=%s')"
   midnight=$(date -d "$today 0" +%s)
   secs_sincemid=$((now - midnight))

   # Detect just past midnight
   if (( secs_sincemid > 0 )) && (( secs_sincemid < 60 * 14 )) ; then

# Other scripts are reading zhone stats,
# reseting counters here causes problems
#      elinks http://$login:$passwd@$ipaddr/statsifcreset.html > /dev/null 2>&1
#      rm $tmpfile_p

      echo
      echo "Reset Zhone statistics accumulators @ $(date)"
      # reset accumulating files
      # Iterate through interfaces
      for intf in "Fib" "GE1" "GE2" "GE3" "GE4" ; do
         echo "0 0 0 0" > /tmp/zhone_t$intf
      done

      # email packet totals for the day
      {
      echo "Packet total email sent $(date)"
      echo
      # Iterate through interfaces
      for intf in "Fib" "GE1" "GE2" "GE3" "GE4" ; do
         env LC_ALL=en_US.UTF-8 printf "%s:\t  %'13d  %'10d   %'13d  %'10d\n" $intf ${acc_rxb[$intf]} ${acc_rxf[$intf]} ${acc_txb[$intf]} ${acc_txf[$intf]}
      done
      echo
      echo "top ten"
      echo $PATH
      echo
      /home/gunn/bin/top10.sh
      } > $email_file

      send_email "Zhone Daily pkt totals for $(date --date="yesterday" "+%b %d %Y")" "$email_file"

      # update history file
      yesterdate=$(date --date="yesterday" "+%Y%m%d")
      for intf in "Fib" "GE1" "GE2" "GE3" "GE4" ; do
         env LC_ALL=en_US.UTF-8 printf "%s %s:\t  %'13d  %'10d   %'13d  %'10d\n" $yesterdate $intf ${acc_rxb[$intf]} ${acc_rxf[$intf]} ${acc_txb[$intf]} ${acc_txf[$intf]}
      done >> $history_file
   fi
else
   echo "Counters not reset @ midnight"
fi

echo "2: seconds since last hour: $(( $(date +%s) %3600 )), since midnight: $secs_sincemid"

# Sends an email everytime script is called
# Kept around for reference??
if [ ! -z "$testcode" ] ; then
   {
      echo "email sent $(date):"
      echo
      # Iterate through interfaces
      for intf in "Fib" "GE1" "GE2" "GE3" "GE4" ; do
         env LC_ALL=en_US.UTF-8 printf "%s:\t  %'13d  %'10d   %'13d  %'10d\n" $intf ${acc_rxb[$intf]} ${acc_rxf[$intf]} ${acc_txb[$intf]} ${acc_txf[$intf]}
      done
   } > $email_file
   send_email "Zhone pkt totals for $(date "+%b %d %Y")" "$email_file"
fi

exit 0
