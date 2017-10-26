#!/bin/sh

# CBW read pump house temperatures

PATH=/usr/bin:/bin
user=$(whoami)
GETDATA="/home/$user/bin/pkt_getdata.sh"

##########################################################################################
################ EDIT THE FOLLOWING LINES TO MATCH YOUR CONFIGURATION ####################
##########################################################################################

UNIT=m 				# "m" for metric units or "e" for english units
MNTPNT="/media/backup/rrd"
TMPDIR="$MNTPNT/var/tmp/pktcnt"		# Where the temp files will be stored. NO TRAILING SLASH
RRDDIR="$MNTPNT/var/lib/pkt/rrdpkts"	# This should be the same as RRDDIR in db_pktbuilder.sh

WWWUSER=www-data			# The web server user
WWWGROUP=www-data			# The web server group

DEBUG=n				# Enable debug mode (y/n).
				# When debug mode is enabled, the DB's are not updated

	if [ -d "${TMPDIR}" ];
		then
			cd ${TMPDIR}
		else
			mkdir ${TMPDIR}
			chown ${WWWUSER}:${WWWGROUP} ${TMPDIR}
			chmod 777 ${TMPDIR}
			cd ${TMPDIR}
	fi

	cd ${TMPDIR}
	pktdata=$($GETDATA)
	rxbytes=$(echo $pktdata | cut -d' ' -f1)
	txbytes=$(echo $pktdata | cut -d' ' -f2)

		if [ ${DEBUG} = "y" ]
		   then
		        echo "pktdata: $pktdata"
			echo "Values found"
			echo "==============="
			echo "Fiber rx bytes : $rxbytes"
			echo "Fiber tx bytes : $txbytes"

		   else
			rrdtool update ${RRDDIR}/fiberrxbytes.rrd N:${rxbytes}
			rrdtool update ${RRDDIR}/fibertxbytes.rrd N:${txbytes}
		fi

