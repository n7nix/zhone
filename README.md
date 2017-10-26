## Scripts for Zhone packet statistic graph

#### install rrdtool
```
apt-get update
apt-get install rrdtool librrds-perl libxml-simple-perl
```
#### scripts

* Used pktwatch.sh to develop pkt_getstats.sh
* Utilities used to display stats, not used for RRD graphing
```
pkt_getstats.sh
pktwatch.sh
```
* create directory RRDDIR /home/gunn/var/lib/cbw/rrdtemp

* Note: The RRDDIR dirctory is used for database files & graph image files and needs to be consistent in these files:
```
pktgestats.cgi
db_gepktbuilder.sh
db_pktstatsupdate.sh

pktfiberstats.cgi
db_fiberpktbuilder.sh
db_fiberpktstatsupdate.sh
```

* run db_gepktbuilder.sh
* run db_pktstatsupdate.sh as cron job every 5 min.
  - this calls script pkt_getstats.sh with argument of Interface name
  - Fib, GE1, GE2, GE3, GE4

#### crontab

```
# crontab entry
*/5 *  * * *  /home/gunn/bin/db_pktstatsupdate.sh
```
```
cp db_pktstatsupdate.sh ~/bin
# two common directories, use one only
cp *.cgi /usr/lib/cgi-bin
cp *.cgi /var/www/cgi-bin
```
#### permissions
* setup owner group
```
cd /var/www
chown -R www-data:www-data cgi-bin
```

#### March 24, 2016
* Changed RRDDIR data dir to /media/disk/rrd/var/lib/pkt/rrdzhone
* Was here: RRDDIR /home/gunn/var/lib/pkt/rrdzhone
```
cd /home/gunn/var/lib/pkt/
chown -R www-data:www-data rrdtemp
```

#### What to graph for each interface


* 5 Interfaces: Fiber, GE1-GE4
```
tx: bytes frames
rx: bytes frames
```
