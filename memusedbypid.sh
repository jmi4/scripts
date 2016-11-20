#!/bin/bash
# modified from: http://stackoverflow.com/a/6854301/2847068
# Usage is running the script and passing the pid as the first argument.

MYPID=$1

echo "=======";
echo PID:$MYPID
echo "--------"
Rss=`echo 0 $(cat /proc/$MYPID/smaps  | grep Rss | awk '{print $2}' | sed 's#^#+#') | bc;`
Shared=`echo 0 $(cat /proc/$MYPID/smaps  | grep Shared | awk '{print $2}' | sed 's#^#+#') | bc;`
Private=`echo 0 $(cat /proc/$MYPID/smaps  | grep Private | awk '{print $2}' | sed 's#^#+#') | bc;`
Swap=`echo 0 $(cat /proc/$MYPID/smaps  | grep Swap | awk '{print $2}' | sed 's#^#+#') | bc;`
Pss=`echo 0 $(cat /proc/$MYPID/smaps  | grep Pss | awk '{print $2}' | sed 's#^#+#') | bc;`

Mem=`echo "$Rss + $Shared + $Private + $Swap + $Pss"|bc -l`

echo "Rss     " $(($Rss / 1024 / 1024))" GB"
echo "Shared  " $(($Shared / 1024 / 1024))" GB"
echo "Private " $(($Private / 1024 / 1024))" GB"
echo "Swap    " $(($Swap / 1024 / 1024))" GB"
echo "Pss     " $(($Pss / 1024 / 1024))" GB"
echo "=================";
echo "Mem     " $(($Mem / 1024 / 1024))" GB"
echo "=================";
