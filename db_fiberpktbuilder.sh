#!/bin/bash

# RRDCBW

PATH=/usr/bin:/bin

MNTPNT="/media/backup/rrd"
TMPDIR="$MNTPNT/var/tmp/pktcnt"		# Where the temp files will be stored. NO TRAILING SLASH
RRDDIR="$MNTPNT/var/lib/pkt/rrdpkts"	# This should be the same as RRDDIR in db_fiberstatsupdate.sh


#######################################################################################
### YOU SHOULD NOT HAVE TO EDIT ANYTHING BELOW THIS LINE ##############################
#######################################################################################

clear

echo ""
echo "RRDzhone : fiber database builder"
echo "-----------------------------"
echo "Are you sure you want to create the database files ?"
echo -n "IT WILL OVERWRITE EXISTING DATA (y/n) "
read ANSWER
echo ""


if [ ${ANSWER} = "n" ]
then
	echo " "
	echo "Exiting..."
	echo " "
	exit 0

elif [ ${ANSWER} = "y" ]
then
	cd

	if [ ! -d ${RRDDIR} ]
	then
		mkdir ${RRDDIR} -p
	fi

	rrdtool create ${RRDDIR}/fiberrxbytes.rrd \
	--step 300 \
	DS:fiberrxbytes:GAUGE:600:0:4294967296 \
	RRA:AVERAGE:0.5:1:600 \
	RRA:AVERAGE:0.5:6:700 \
	RRA:AVERAGE:0.5:24:775 \
	RRA:AVERAGE:0.5:288:797 \
	RRA:MIN:0.5:1:600 \
        RRA:MIN:0.5:6:700 \
        RRA:MIN:0.5:24:775 \
        RRA:MIN:0.5:288:797 \
	RRA:MAX:0.5:1:600 \
        RRA:MAX:0.5:6:700 \
        RRA:MAX:0.5:24:775 \
        RRA:MAX:0.5:288:797

	rrdtool create ${RRDDIR}/fibertxbytes.rrd \
        --step 300 \
        DS:fibertxbytes:GAUGE:600:0:4294967296 \
        RRA:AVERAGE:0.5:1:600 \
        RRA:AVERAGE:0.5:6:700 \
        RRA:AVERAGE:0.5:24:775 \
        RRA:AVERAGE:0.5:288:797 \
        RRA:MIN:0.5:1:600 \
        RRA:MIN:0.5:6:700 \
        RRA:MIN:0.5:24:775 \
        RRA:MIN:0.5:288:797 \
        RRA:MAX:0.5:1:600 \
        RRA:MAX:0.5:6:700 \
        RRA:MAX:0.5:24:775 \
        RRA:MAX:0.5:288:797

	echo ""
	echo "Database files built..."
	echo ""
	echo "Listing database files created under ${RRDDIR} :"
	ls -lh ${RRDDIR}/
	echo ""
	echo "Now, you can setup the db_pktstatsupdate.sh script and set up a cron to run it"

else

	echo " "
	echo " y or n only!"
	echo "Exiting..."
	echo ""
	exit 1

fi
