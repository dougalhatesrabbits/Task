#!/bin/bash

# Author: David Brooke for Third Light
#
# Date: 25.5.2018
#
# Original Version: 1.0
#
# Functionality: Called by the parent Test harness script "callTask.sh" 
#
#                Runs as a seperate background process, gathering total system metrics
#                whilst the parent process is running
#
# =================
# Version history
# =================
# 1.1
# 26.5.2018
# David Brooke
# Added logging.
# -----------------

gHERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$gHERE"
if [ $? -gt 0 ]; then
        printf "\nCould not cd to "$HERE"\n"
fi

LOG="$HERE/log/logSummary.log"
# exec 3>&1 4>&2
# trap 'exec 2>&4 1>&3' 0 1 2 3 RETURN
# exec 1>"$LOG" 2>&1

printf "\e[37m\n$(date +"%Y-%m-%d@%T") \e[0m\t$0 \e[1m\e[32mStart...\e[0m\n"

printf "\e[37m Nr Files to process is: \e[0m$numFiles\n" | tee "$LOG"
printf "\e[37m TOP Interval = \e[0m$INT seconds \e[37m(can increment in 0.01)\e[0m\n" | tee "$LOG"
printf "\e[37m TOP Iterations = \e[0m$NUM\n" | tee "$LOG"

# Monitoring
# This impacts the script performance
top -d $INT -n $NUM -b | awk -v date="$(date +"%Y-%m-%d@%T")" '/convert/ || /gm/ || /econvert/ || /mogrify/ { print date, $0 }' \
    > "$RESULTS"/TopTaskSummary.csv &      
top -d $INT -n $NUM -b | awk '{ print $0 }' > "$RESULTS"/TopSystemSummary.csv & 
vmstat -nat 1 $NUM > "$RESULTS"/VmstatSummary.csv &

printf "\e[37m$(date +"%Y-%m-%d@%T") \e[0m\t$0 \e[1m\e[32mDone\e[0m\n"
