eval "$(date +'today=%F now=%s')"
hour=13
midnight=$(date -d "$today $hour" +%s)
secs_sincemid=$((now - midnight))
just_aftermid=$(( ($hour * 60)+(60 * 15) ))

echo "Seconds since midnight: $secs_sincemid, now: $now"
echo "Just after midnight: $just_aftermid"
echo "Reset Zhone statistics counter @ $(date)"