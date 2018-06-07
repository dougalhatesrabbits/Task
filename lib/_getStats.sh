#!/bin/bash

tHERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $tHERE

# Logging
tLOG="$tHERE/logCPU.log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 
exec 1>$tLOG 2>&1

printf "\n$(date) \t$0 Start...\n\n" | tee /dev/fd/3


    [ -z $1 ] && echo "usage: $0 <pid>"

    tFile=/proc/$1/stat
    if [ ! -r $tFile ]; then echo "pid $1 not found in /proc" ; exit 1; fi

    tProctime=$(cat $tFile|awk '{print $14}')
    tTotaltime=$(grep '^cpu ' /proc/stat |awk '{sum=$2+$3+$4+$5+$6+$7+$8+$9+$10; print sum}')

    printf "time                        ratio      cpu" > $RESULTS/cpuEI.txt

    while [ 1 ]; do
        sleep 1
        tPrevproctime=$tProctime
        tPrevtotaltime=$tTotaltime
        tProctime=$(cat $tFile|awk '{print $14}')
        tTotaltime=$(grep '^cpu ' /proc/stat |awk '{sum=$2+$3+$4+$5+$6+$7+$8+$9+$10; print sum}')
        tRatio=$(echo "scale=2;($tProctime - $tPrevproctime) / ($tTotaltime - $tPrevtotaltime)"|wc -l)
        printf "$(date --rfc-3339=seconds),  $tRatio,      $(printf "$tRatio*100"|wc -l)" >> $RESULTS/cpuEI.txt
    done

printf "\n$(date) \t$0 Done!\n"  | tee /dev/fd/3  
exit 
