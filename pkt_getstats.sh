#/bin/bash
#
# Utility to display statistics - not used in crontab
#
DEBUG_FLAG="false"
zhone_cfgfile="/etc/zhone.conf"

login=
passwd=
ipaddr=

# Read configuration file for login credentials & ip address
login=$(grep "LOGIN" $zhone_cfgfile | cut -d"=" -f2)
passwd=$(grep "PASSWORD" $zhone_cfgfile | cut -d"=" -f2)
ipaddr=$(grep "IP_ADDRESS" $zhone_cfgfile | cut -d"=" -f2)

statbuf=$(elinks -dump 1 http://$login:$passwd@$ipaddr/statsifc.html)

case $1 in
    f|F)
        ind=15
        intf="Fib"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

       ;;
    1)
        ind=$((15+18))
        intf="GE1"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

    	;;
    2)
        ind=$((15+(18*2)))
        intf="GE2"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

    	;;
    3)
        ind=$((15+(18*3)))
        intf="GE3"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

    	;;
    4)
        ind=$((15+(18*4)))
        intf="GE4"
	if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))
        env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf

    	;;
    *)
        if [ "$DEBUG_FLAG" = "true" ] ; then
	   echo "$statbuf"
	   echo
	   echo  "<---->"
	   echo
	fi
        ind=15
        for intf in "Fib" "GE1" "GE2" "GE3" "GE4" ; do

           if_rxb=$(echo  $statbuf | cut -d '|' -f$ind)
	   if_rxf=$(echo  $statbuf | cut -d '|' -f$((ind+1)))
	   if_txb=$(echo  $statbuf | cut -d '|' -f$((ind+4)))
	   if_txf=$(echo  $statbuf | cut -d '|' -f$((ind+5)))

           env LC_ALL=en_US.UTF-8 printf "%s\t  %'13d  %'10d   %'13d  %'10d\n" $intf $((if_rxb)) $((if_rxf)) $if_txb $if_txf
           ind=$((ind+=18))
        done

	;;
esac

exit 0