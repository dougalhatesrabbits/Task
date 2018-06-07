#!/bin/bash

# Author: David Brooke for Third Light
#
# Date: 25.5.2018
#
# Original Version: 1.0
#
# Functionality: The parent calling program.
#
#                To test the performance of 3 freely available image processing converter tools.
#                A Test harness on 
#
#                1. ImageMagick
#                2. GraphicsMagick
#                3. ExactImage 
#
#                This script uses the OS 'time' utility to record the execution times of each tool
#                rather than the 'time' options availabe withinn some of the tools themselves.
#                Regard should be made of this and further testing should be made to check if the
#                options provided within the tools offer a better or more accurate set of results.
#
#                Additional IO,CPU monitoring using 'top' and 'vmstat' is offered more can be added if required.
#                An example has been provided for just one of the tests.
#                Regard should be made of the impact that adding these have on the true test results.
#
#
# Usage:         Command line call = ./bash.sh [[0-9]] - optional arguments provide number of test iterations
#
#                Main = Test individual tools or as a run set by commenting/uncommenting each function in Main.
#                       Optionally add/remove the image tool built-in compiled options as the test function arguments in Main.
#                       e.g. testGM_mog [-size 500x500 -resize 500x500] etc.
#
#                /logs = ./logtask.log - timestamped stdout and stderr with signal traps
#
#                /src = Directory of original images pre-testing.
#                /tgt = Directory of thumbnails post-tested.
#                /tmp = Directory for test harness files. Holds a snaphot of the IO/CPU type tests on each run 
#                       and a cummulative set for each of the time tests. 
#                /results = All the good stuff goes here
#                /lib = supporting scripts
#                /sudo = scripts that need root or sudo privilege
#
#
#
# =================
# Version history
# =================
# 1.1
# 23.5.2018
# David Brooke
# Added optional arguments for compiled options.
# -----------------
# 1.2
# 24.5..2018
# David Brooke
# Added IO/CPU monitoring. Added Validation checks.
# Improved summary reports and error trapping.
#
# =================

export HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HERE"
if [ $? -gt 0 ]; then
        printf "\nCould not cd to "$HERE"\n"
fi

# Logging
LOG="$HERE/log/logCall.log"
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3 255 RETURN
#exec 1>"$cLOG" 2>&1

clear
printf "\e[37m$(date +"%Y-%m-%d@%T") \e[0m\t$0 $$ \e[1m\e[32mStart...\e[0m\n" | tee -i "$LOG"

validateTests () {
    # for loop here
    printf "\e[37m\n$(date +"%Y-%m-%d@%T") \e[0m\tValidate Tests\n\t\t\t--------------\n" | tee -ai "$LOG"
    
    filesList="post_files.txt pre_files.txt" 
    formatsList="post_formats.txt pre_formats.txt"
    errorsList="post_errors.txt pre_errors.txt"

    for list in $filesList; do             
        for f in "$TGT"/*; do file "$f" 2>>"$LOG"; done > "$RESULTS"/$list
        if [ $? -eq 0 ]; then
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\e[32m\tPost files - validated\n" | tee -ai "$LOG"        
        else
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\e[33m\tPost files - Could not open some Post Files\n" | tee -ai "$LOG"  
        fi
    done

    for list in $formatsList; do
        for f in "$TGT"/*; do identify -format "%wx%h\n\n" "$f" 2>>"$LOG"; done > "$RESULTS"/$list   
        if [ $? -eq 0 ]; then
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\e[32m\tPost formats - validated\n" | tee -ai "$LOG" 
        else
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\\e[33mtPost formats - could not open some Post Format Files\n" | tee -ai "$LOG" 
        fi
    done

    for list in $errorsList; do   
        for f in "$TGT"/*; do identify  "$f" 2>>"$LOG"; printf "$f $? errors\n"; done > "$RESULTS"/$list
        if [ $? -eq 0 ]; then
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\e[32m\tErrors - validated\e[0m\n" | tee -ai "$LOG"       
        else
            printf "\e[37m$(date +"%Y-%m-%d@%T")\e[0m\e[33m\tCould not open some Post Error Files\n" | tee -ai "$LOG"  
        fi
    done
}

# --------------------------------
# Now collate the results /tmp into /results
# --------------------------------
resultSummary () {
    timeList="timeIM_C timeIM_M timeGM_C timeGM_B timeGM_M timeEI"
    topList="topIM_C topIM_M topGM_C topGM_B topGM_M topEI"

    printf "\nPrinting summaries..." | tee -ai "$LOG"
    for file in $timeList; do
        if [ -f "$TEMP"/$file.txt ]; then
            awk 'BEGIN { OFS=", "; printf "TimeStamp, Real Time(s), USER Non-Kernel Time(s), SYSTEM Kernel Time(s)\n" } \
            { printf "%s" ( NR%5 == 0?''RS:OFS ),$2 }' "$TEMP"/$file.txt 2>>"$LOG" > "$RESULTS"/$file.csv
        else
            printf "\e[37m\n$(date)\e[0m Could not write "$TEMP"/$file.txt to "$RESULTS"/$file.csv" | tee -ai "$LOG"
        fi
    done

    for file in $topList; do
        if [ -f "$TEMP"/$file.txt ]; then
            awk 'BEGIN { OFS=", "; printf "TIMESTAMP, PID, USER, PRIORITY, NICE, VIRT, RESIDENT, SHARED, STATUS, %CPU, %MEM, TIME+, COMMAND\n" } \
            { print }' "$TEMP"/$file.txt 2>>"$LOG" > "$RESULTS"/$file.csv
        else
            printf "\e[37m\n$(date)\e[0m Could not write "$TEMP"/$file.txt to "$RESULTS"/$file.csv" | tee -ai "$LOG"
        fi
    done

    printf "\n\e[37m$(date) \e[0m\tSummaries are in "$RESULTS"/*summary.csv\n" | tee -ai "$LOG"
}

#=============================
#        Main
#=============================
#tHERE=$(find $HOME -not -path '*/\.*' -type f -name "task.sh" | dirname)

export TEMP="$HERE/tmp" 
export SRC="$HERE/src"
export TGT="$HERE/tgt"
export RESULTS="$HERE/results"
export numFiles="$(find $SRC -type f | wc -l)"
export INT=1
export taskINT=1
let NUM="$numFiles * 15"
export NUM
export taskNUM=10
SIZE='500x500'

# Check $0 args[]
if [ $# -eq 0 ]; then
    REPEAT=1
elif [ $1 = "-h" ] || [ $1 = "-help" ]; then
  printf "...help...\n"
  printf "USAGE: $0 [n --number]\n\n"
elif ! [ "$1" -eq "$1" 2> /dev/null ]; then
    printf "ERROR: "$1" is not a number!\n" | tee -i "$LOG"
    printf "USAGE: $0 [n --number]\n\n"
    exit 1
else
    REPEAT=$1
fi


if [ $numFiles -lt 1 ]; then
    printf "\nNo files to process...exiting\n\n" | tee -ai "$LOG"
    exit 1
fi

$HERE/lib/getStats.sh
source $HERE/lib/task.sh

COUNT=1
while [ $COUNT -le $REPEAT ]
do
    printf "\e[37m\n$(date +"%Y-%m-%d@%T") \e[0m\t$0 > task.sh $$ \e[1m\e[32mStart...\e[0m\n" | tee -ai "$LOG"
    testIM "-resize $SIZE" 2>>"$LOG" 
    testGM "-resize $SIZE" "+profile \"*\"" 2>>"$LOG"
    testEI "--size $SIZE" 2>>"$LOG"
    printf "\e[37m\n$(date +"%Y-%m-%d@%T") \e[0m\t$0 > task.sh $$ \e[1m\e[32mDone\e[0m\n" | tee -ai "$LOG"
    ((COUNT++))
done

validateTests
resultSummary

printf "\e[37m\n$(date +"%Y-%m-%d@%T") \e[0m\t$0 $$ \e[1m\e[32mAll Done\e[0m\n-----------------------------------------------------\n" | tee -ai "$LOG"
printf "\n$0 took \e[1m$SECONDS \e[0mseconds\n\n" | tee -ai "$LOG"
exit 
