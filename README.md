## Scripts for Zhone packet statistic graph

  * Accumulates counters for daily totals
  * Display graph for fiber Rx & Tx byte counts
  * Display graph of GE1-4 Rx & Tx byte counts

#### install rrdtool
```
apt-get update
apt-get install rrdtool librrds-perl libxml-simple-perl
```
#### scripts

* Used pkt_getstats.sh to develop pktwatch.sh
* Utilities used to display stats, not used for RRD graphing
  * pkt_getstats.sh - Displays the current counters on the Zhone
  * pktwatch.sh - Accumulates counters for daily totals

* create directory RRDDIR /home/$user/var/lib/cbw/rrdtemp

* Note: The RRDDIR dirctory is used for database files & graph image files and needs to be consistent in the following files:
```
pktgestats.cgi
db_gepktbuilder.sh
db_pktstatsupdate.sh

pktfiberstats.cgi
db_fiberpktbuilder.sh
db_fiberpktstatsupdate.sh
```

#### Initialize rrd database files
* There are 2 database files, one for just the fiber interface & another for the 4 GiG Ethernet interfaces
  * run db_fiberpktbuilder.sh
  * run db_gepktbuilder.sh

#### Collect Packet Data
* run db_pktstatsupdate.sh as cron job every 5 min.
  - this calls script pkt_getdata.sh which scrapes the zhone stats web page and puts it in an easily parsable format for each of the interfaces
  - Interfaces on Zhone: Fib, GE1, GE2, GE3, GE4

##### crontab

```
# crontab entry
*/5  *   *   *   *  /home/$user/bin/db_pktstatsupdate.sh
0    *   *   *   *  /bin/bash /home/$user/bin/pktwatch.sh > /dev/null 2>&1
```

##### Put scripts in a common directory

```
cp db_fiberstatsupdate.sh ~/bin
cp db_pktstatsupdate.sh ~/bin
cp packetwatch.sh ~/bin
cp pkt_getdata.sh ~/bin
cp pkt_getstats.sh ~/bin
cp dhcp_chk.sh ~/bin
# two commonly used directories for cgi, use one only
cp *.cgi /usr/lib/cgi-bin
cp *.cgi /var/www/cgi-bin
```
#### permissions
* setup owner group
```
cd /var/www
chown -R www-data:www-data cgi-bin
```
```
cd /home/$user/var/lib/pkt/
chown -R www-data:www-data rrdtemp
```

#### config file

* set up file with credentials for Zhone home router
  * Format of file: /etc/zhone.conf
```
LOGIN=joeblow
PASSWORD=secret
IP_ADDRESS=10.9.8.7
```

#### What to graph for each interface

* Only graph total bytes
* pktwatch.sh script accumulates totals for both bytes & frames

* 5 Interfaces: Fiber, GE1-GE4
```
tx: bytes frames
rx: bytes frames
```
