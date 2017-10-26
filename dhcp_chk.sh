#!/bin/bash
#
# File: dhcp_chk.sh
#  - when zhone dhcp table changes send an email
#
#DEBUG=1

scriptname="`basename $0`"
user=$(whoami)

SYSOP_EMAIL="$user@$(hostname)"
tmpdir="/tmp"
zhone_cfgfile="/etc/zhone.conf"

dhcp_last_file="$tmpdir/dhcplast.txt"
dhcp_test_file="$tmpdir/dhcptest.txt"
dhcp_current_file="$tmpdir/dhcpcurr.txt"
dhcp_cmp_curr_file="$tmpdir/dhcpcmp_curr.txt"
dhcp_tmp_curr_file="$tmpdir/dhcpcmp_tmp_curr.txt"
dhcp_cmp_last_file="$tmpdir/dhcpcmp_last.txt"

login=
passwd=
ipaddr=

## ============ functions ============

function dbgecho { if [ ! -z "$DEBUG" ] ; then echo "$*"; fi }

# ==== function send_email
function send_email() {
   # Only send email if DEBUG not defined
   if [ -z "$DEBUG" ] ; then
      subject="dhcp changed on $(date "+%b %d %Y")"
      mutt -s "$subject" $SYSOP_EMAIL <<< "$1"
   else
      echo "Debug defined, not sending email"
      echo "email body: $1"
   fi
}

# ==== function format_space()
# Pad string with spaces
#
# arg1 = string
# arg2 = length to pad
#
function format_space () {
   local whitespace=" "
   # Define a single white space for column formating
   singlewhitespace=" "

   strarg="$1"
   lenarg="$2"
   strlen=${#strarg}
#   echo "format_space len: $lenarg, str: $strlen"
   whitelen=$(( lenarg-strlen ))
   for (( i=0; i<whitelen; i++ )) ; do
       whitespace+="$singlewhitespace"
    done;
# return string of whitespace(s)
    echo -n "$whitespace"
}

# ==== function print_ip_list()
# If any arg is passed then include active true/false field
# calling `print_ip_list` will output 5 fields
# calling `print_ip_list 1` will output 4 fields

function print_ip_list() {
tr -s "\n" < $dhcp_current_file > $dhcp_test_file
#sed -i -e 's/                     */|noname|/' $dhcp_test_file
sed -i -e 's/   */|/g' $dhcp_test_file

#sed 's/^/|/;s/\.\.*/|/;s/$/|/'
#sed 's/   */|/g' $dhcp_test2_file > $dhcp_test_file
#sed "s/\r//" $dhcp_current_file > $dhcp_test_file

#tr "\r" "\n" < $dhcp_current_file > $dhcp_test_file
#echo "file test"
#cat $dhcp_test_file
#echo "file test end"

i=0;
while read -r line ; do

  gdline=$(echo $line | grep -i "brvlan1530")
  ret=$?

#  echo "check: $i $ret $gline"
  if [ $ret -eq 0 ] ; then

#     echo "result0: $i $gdline"
#     teststr=$(sed -n -e 's/^.*True/^.*True/p' <<< $gdline)
#     echo "Test string: $teststr"
#     ${MYVAR%pattern}       # delete shortest match of pattern from the end
#     ${MYVAR%%pattern}      # delete longest match of pattern from the
      # end

      grep "True" <<< $gdline > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
#        echo "Test string1: ${gdline%True*}"
#        echo "Test string2: $(sed 's/|$//'<<< ${gdline%%True})"
        gdline=$(echo ${gdline%%True*}True)
      fi
      grep "False" <<< $gdline > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
#        echo "Test string1: ${gdline%%False*}"
#        echo "Test string2: $(sed 's/|$//'<<< ${gdline%%True})"
        gdline=$(echo "${gdline%%False*}False")
      fi
      occur=$(grep -o "|" <<< "$gdline" | wc -l)

      if [ "$occur" -lt 7 ] ; then
         gdline=$(echo $gdline | cut -d'|' -f1,2,3,6,7)
         hostname="NoName"
      else
         gdline=$(echo $gdline | cut -d'|' -f2,3,4,7,8)
         hostname=$(cut -d'|' -f1 <<< $gdline)
      fi

      # get rid of any spaces in hostname so file can be sorted
      hostname=$(echo ${hostname// /_})
      whitespace=$(format_space "$hostname" 24)

#     printf " %s%s %s  %s  %s  %s\n" $host_name $(format_space $hostname 22) "$(cut -d'|' -f2 <<< $gdline)" "$(cut -d'|' -f3 <<< $gdline)" $(cut -d'|' -f4 <<< $gdline) $(cut -d'|' -f5 <<< $gdline)
#     printf " %s %s %s  %s  %s  %s\n" $hostname $whitespace "$(cut -d'|' -f2 <<< $gdline)" "$(cut -d'|' -f3 <<< $gdline)" $(cut -d'|' -f4 <<< $gdline) $(cut -d'|' -f5 <<< $gdline)

#echo "(${#whitespace}) $hostname $whitespace $(cut -d'|' -f2 <<< $gdline) $(cut -d'|' -f3 <<< $gdline) $(cut -d'|' -f4 <<< $gdline) $(cut -d'|' -f5 <<< $gdline)"
#echo "($occur) $hostname $whitespace $(cut -d'|' -f2 <<< $gdline) $(cut -d'|' -f3 <<< $gdline) $(cut -d'|' -f4 <<< $gdline) $(cut -d'|' -f5 <<< $gdline)"

# Check number of arguments passed to this routine
# - if there is an arg then do not include the active True/False field

      if [ $# -eq 0 ] ; then
         echo " $hostname $whitespace $(cut -d'|' -f2 <<< $gdline) $(cut -d'|' -f3 <<< $gdline) $(cut -d'|' -f4 <<< $gdline) $(cut -d'|' -f5 <<< $gdline)"
      else
         echo " $hostname $whitespace $(cut -d'|' -f2 <<< $gdline) $(cut -d'|' -f3 <<< $gdline) $(cut -d'|' -f4 <<< $gdline)"
      fi
#     echo "result1: $1 $gdline"

      ((i+=1))
   fi

#  if (( i > 9 )) ; then
#     echo "finished"
#     exit
#  fi
done < $dhcp_test_file
}


# ==== Main

# Is mutt installed?

type -P mutt &>/dev/null
if [ $? -ne 0 ] ; then
  echo "$scriptname: Need to Install mutt package"
  exit 1
fi

# Read configuration file for login credentials & ip address
login=$(grep "LOGIN" $zhone_cfgfile | cut -d"=" -f2)
passwd=$(grep "PASSWORD" $zhone_cfgfile | cut -d"=" -f2)
ipaddr=$(grep "IP_ADDRESS" $zhone_cfgfile | cut -d"=" -f2)

# Does last dhcp file exist"
if [ ! -f "$dhcp_current_file" ] || [ ! -f $dhcp_cmp_curr_file ] ; then

   echo "Creating dhcp reference file: $dhcp_current_file"

   elinks -dump 1 http://$login:$passwd@$ipaddr/dhcpinfo.html > $dhcp_current_file
   print_ip_list 1 > $dhcp_cmp_curr_file

else
   # Make current file last file & create new current files.
   cp $dhcp_current_file $dhcp_last_file
   cp $dhcp_cmp_curr_file $dhcp_cmp_last_file

   # Only run elinks if DEBUG is not defined
   if [ -z "$DEBUG" ] ; then
      elinks -dump 1 http://$login:$passwd@$ipaddr/dhcpinfo.html > $dhcp_current_file
   else
      echo "Debug defined, not running elinks"
   fi

   print_ip_list 1 > $dhcp_cmp_curr_file
   print_ip_list   > $dhcp_tmp_curr_file

   diffbuf=$(diff $dhcp_cmp_curr_file $dhcp_cmp_last_file)

   if [ $? -ne 0 ] ; then
      change_cnt=$(grep -vf $dhcp_cmp_curr_file $dhcp_cmp_last_file | wc -l)

      diffbuf=$(printf "total addresses: %s, active: %s, INactive: %s,  changed: %s\n\n %s\n" $(cat $dhcp_cmp_curr_file | wc -l) $(grep -c "True" $dhcp_tmp_curr_file) $(grep -c "False" $dhcp_tmp_curr_file) $change_cnt "$diffbuf" )

      echo "$change_cnt lines have changed"
      send_email "$diffbuf"

if [ ! -z "$testcode" ] ; then
      if [ "$change_cnt" -eq "1" ] ; then
         echo "Only 1 line changed, checking True/False"
	 filechg1=$(grep -vf $dhcp_cmp_curr_file $dhcp_cmp_last_file | tr -s ' ' | cut --complement -d " " -f6)
	 filechg2=$(grep -vf $dhcp_cmp_last_file $dhcp_cmp_curr_file | tr -s ' ' | cut --complement -d " " -f6)

	 if [ "$filechg1" == "$filechg2" ] ; then
	    echo "Only active True/False changed. Don't do anything."
            dbgecho "Compared these 2 lines:"
	    dbgecho " $filechg1"
	    dbgecho " $filechg2"
	 else
	    send_email "$diffbuf"
	 fi
      else
	 send_email "$diffbuf"
      fi
fi

   else
      # No change in dhcp table
      if [ ! -z $DEBUG ] ; then
         change_cnt=$(grep -vf $dhcp_cmp_curr_file $dhcp_cmp_last_file | wc -l)
         diffbuf=$(printf "total addresses: %s, active: %s, INactive: %s,  changed: %s\n\n %s\n" $(cat $dhcp_cmp_curr_file | wc -l) $(grep -c "True" $dhcp_tmp_curr_file) $(grep -c "False" $dhcp_tmp_curr_file) $change_cnt)

         echo "$change_cnt lines have changed"
         echo "No change in dhcp log."
         echo "$diffbuf"
         sort -k 5 $dhcp_tmp_curr_file
      fi
   fi
fi

dbgecho "finished"
exit
