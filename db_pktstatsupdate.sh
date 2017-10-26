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

DEBUG=y			# Enable debug mode (y/n).
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
	fib_rxbytes=$(echo $pktdata | cut -d' ' -f1)
	fib_txbytes=$(echo $pktdata | cut -d' ' -f2)
	ge1_rxbytes=$(echo $pktdata | cut -d' ' -f3)
	ge1_txbytes=$(echo $pktdata | cut -d' ' -f4)
	ge2_rxbytes=$(echo $pktdata | cut -d' ' -f5)
	ge2_txbytes=$(echo $pktdata | cut -d' ' -f6)
	ge3_rxbytes=$(echo $pktdata | cut -d' ' -f7)
	ge3_txbytes=$(echo $pktdata | cut -d' ' -f8)
	ge4_rxbytes=$(echo $pktdata | cut -d' ' -f9)
	ge4_txbytes=$(echo $pktdata | cut -d' ' -f10)

		if [ ${DEBUG} = "y" ]
		   then
		        echo "pktdata: $pktdata"
			echo "Values found"
			echo "==============="
			echo "Fiber bytes rx: $fib_rxbytes, tx: $fib_txbytes"
			echo "GE1   bytes rx: $ge1_rxbytes, tx: $ge1_txbytes"
			echo "GE2   bytes rx: $ge2_rxbytes, tx: $ge2_txbytes"
			echo "GE3   bytes rx: $ge3_rxbytes, tx: $ge3_txbytes"
			echo "GE4   bytes rx: $ge4_rxbytes, tx: $ge4_txbytes"

		   else
			rrdtool update ${RRDDIR}/fiberrxbytes.rrd N:${fib_rxbytes}
			rrdtool update ${RRDDIR}/fibertxbytes.rrd N:${fib_txbytes}
			rrdtool update ${RRDDIR}/ge1rxbytes.rrd N:${ge1_rxbytes}
			rrdtool update ${RRDDIR}/ge1txbytes.rrd N:${ge1_txbytes}
			rrdtool update ${RRDDIR}/ge2rxbytes.rrd N:${ge2_rxbytes}
			rrdtool update ${RRDDIR}/ge2txbytes.rrd N:${ge2_txbytes}
			rrdtool update ${RRDDIR}/ge3rxbytes.rrd N:${ge3_rxbytes}
			rrdtool update ${RRDDIR}/ge3txbytes.rrd N:${ge3_txbytes}
			rrdtool update ${RRDDIR}/ge4rxbytes.rrd N:${ge4_rxbytes}
			rrdtool update ${RRDDIR}/ge4txbytes.rrd N:${ge4_txbytes}
		fi

