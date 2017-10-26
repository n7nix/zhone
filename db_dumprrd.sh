
MNTPNT="/media/backup/rrd"
TMPPNT="/home/gunn/tmp/rrd"

rrddir="$MNTPNT/var/lib/cbw/rrdtemp"
RRDS="highpumphouse lowpumphouse outsidepumphouse tinyhouse"

for filename in `echo ${RRDS}` ; do
   echo "dumping file: $rrddir/$filename.rrd"
   rrdtool dump $rrddir/$filename.rrd > $TMPPNT/$filename.xml
done

rrddir="$MNTPNT/var/lib/pkt/rrdpkts"
RRDS="fiberrxbytes fibertxbytes ge1rxbytes ge1txbytes ge2rxbytes ge2txbytes ge3rxbytes ge3txbytes ge4rxbytes ge4txbytes"

for filename in `echo ${RRDS}` ; do
   echo "dumping file: $rrddir/$filename.rrd"
   rrdtool dump $rrddir/$filename.rrd > $TMPPNT/$filename.xml
done
