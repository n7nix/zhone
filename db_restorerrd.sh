#!/bin/bash
#
MNTPNT="/tmp"
TMPPNT="/home/gunn/tmp/rrd"
#rrddir="$MNTPNT/var/lib/cbw/rrdtemp"
rrddir="$MNTPNT/lib/cbw/rrdtemp"
RRDS="highpumphouse lowpumphouse outsidepumphouse tinyhouse"

login=
passwd=
ipaddr=

# Get rrd data files from another machine
rsync -av -e ssh $login@$ipaddr:tmp/rrd/* $TMPPNT/

function getinfo()
{
   rrdtool info $rrddir/$1.rrd
}


for filename in `echo ${RRDS}` ; do
   echo "restoring file: $rrddir/$filename.rrd"
   rrdtool restore -f $TMPPNT/$filename.xml $rrddir/$filename.rrd
done

getinfo tinyhouse
