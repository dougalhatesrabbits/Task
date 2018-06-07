#!/bin/bash

# Author: David Brooke for Third Light
#
# Date: 25.5.2018
#
# Original Version: 1.0
#
# Functionality: Called by the parent Test harness script "callTask.sh" 
#
#                Runs in the same process as the parent, gathering metrics
#                on the conversion tools whilst the parent process is running
#
# =================
# Version history
# =================
# 1.1
# 26.5.2018
# David Brooke
# Added logging.
# -----------------

tHERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$tHERE"
if [ $? -gt 0 ]; then
        printf "\nCould not cd to "$tHERE"\n"
fi

# Logging
#tLOG="$HERE/log/logTask.log"
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3 15 RETURN 
#exec 1>"$tLOG" 2>&1

testIM () {
    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess ImageMagick_Convert\e[0m\n" | tee -ai "$TEMP"/timeIM_C.txt
    ( time -p for file in $SRC/*.jpg; do convert $1 $2 $3 "$file" "${file%.jpg}-thumb_1.jpg"; done ) 2>> "$TEMP"/timeIM_C.txt &
    #PID=$(pidof -s convert)
    #printf "\n$(date +"%Y-%m-%d@%T"), IM_Convert, $PID\n" > "$TEMP"/pid.txt
    
    ( top -d $taskINT -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/convert/ { print date, $0 }' ) > "$TEMP"/topIM_C.txt & 
    ( vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatIM_C.csv ) &
    
    wait
    mv "$SRC"/*thumb* "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move "$SRC"/*thumb* to "$TGT"\n"
    fi

    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess ImageMagick_Mogrify\e[0m\n" | tee -ai "$TEMP"/timeIM_M.txt
    cd "$SRC"
    mkdir test   
    ( time -p mogrify -path test $1 $2 $3 "$SRC"/*.jpg; ) 2>> "$TEMP"/timeIM_M.txt &
    #PID=$(pidof -s mogrify)
    #printf "\n$(date +"%Y-%m-%d@%T"), IM_Mogrify, $PID\n" >> "$TEMP"/pid.txt

    ( top -d $taskINT -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/mogrify/ { print date, $0 }' ) > "$TEMP"/topIM_M.txt & 
    ( vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatIM_M.csv ) &

    wait
    for f in test/*.jpg; do mv "$f" "${f%.jpg}-thumb_2.jpg"; done
    mv test/*.jpg "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move test/*.jpg to "$TGT"\n"
    fi
    rmdir test
    if [ $? -gt 0 ]; then
        printf "\nCould not remove test\n"
    fi;
}

testGM () {
    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess GraphicsMagick_Convert\e[0m\n" | tee -ai "$TEMP"/timeGM_C.txt
    ( time -p for file in "$SRC"/*.jpg; do gm convert "$file" $1 $2 $3 "${file%.jpg}-thumb_3.jpg"; done ) 2>> "$TEMP"/timeGM_C.txt &
    #PID=$( pidof -s gm )
    #printf "\n$(date +"%Y-%m-%d@%T"), GM_Convert, $PID\n" >> "$TEMP"/pid.txt
    
    ( top -d $taskINT -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/gm/ { print date, $0 }' ) > "$TEMP"/topGM_C.txt & 
    ( vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatGM_C.csv) & 

    wait
    mv "$SRC"/*thumb* "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move "$SRC"/*thumb* to "$TGT"\n"
    fi

    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess GraphicsMagick_Batch\e[0m\n" | tee -ai "$TEMP"/timeGM_B.txt
    ( time -p for file in "$SRC"/*.jpg; do convert "$file" $1 $2 $3 "${file%.jpg}-thumb_4.jpg"; done | gm  batch ) 2>> "$TEMP"/timeGM_B.txt &
    #PID=$(pidof -s convert)
    #printf "\n$(date +"%Y-%m-%d@%T"), GM_Batch, $PID\n" >> "$TEMP/pid.txt"

    (top -d $taskINT -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/convert/ { print date, $0 }') > "$TEMP"/topGM_B.txt & 
    (vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatGM_B.csv) &

    wait
    mv "$SRC"/*thumb* "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move "$SRC"/*thumb* to "$TGT"\n"
    fi

    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess GraphicsMagick_Mogrify\e[0m\n" | tee -ai "$TEMP"/timeGM_M.txt
    cd "$SRC"
    mkdir test
    if [ $? -gt 0 ]; then
        printf "\nCould not create "$SRC"/test\n"
    fi
    ( time -p gm mogrify -output-directory test $1 $2 $3 "*.jpg"; ) 2>> "$TEMP"/timeGM_M.txt &
    #PID=$( pidof -s gm )
    #printf "\n$(date +"%Y-%m-%d@%T"), GM_Mogrify, $PID\n" >> "$TEMP"/pid.txt

    (top -d $taskINT -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/gm/ { print date, $0 }') > "$TEMP"/topGM_M.txt & 
    (vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatGM_M.csv) &

    wait
    for f in test/*.jpg; do mv "$f" "${f%.jpg}-thumb_5.jpg"; done
    mv test/*.jpg "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move test/*.jpg to "$TGT"\n"
    fi
    rmdir test
    if [ $? -gt 0 ]; then
        printf "\nCould not remove test\n"
    fi;

}

testEI () {
    printf "\e[37m$(date +"%Y-%m-%d@%T")\e[1m\nprocess ExactImage\e[0m\n" | tee -ai "$TEMP"/timeEI.txt
    ( time -p for file in "$SRC"/*.jpg; do econvert -i "$file" $1 $2 $3 -o "${file%.jpg}-thumb_6.jpg"; done ) 2>> "$TEMP"/timeEI.txt  &      
    #PID=$(pidof -s econvert)
    #printf "\n$(date +"%Y-%m-%d@%T"), EI_Convert, $PID\n" >> "$TEMP"/pid.txt

    (top -d 0.2 -n $taskNUM -b | awk  -v date="$(date +"%Y-%m-%d@%T")" '/econvert/ { print date, $0 }') > "$TEMP"/topEI.txt & 
    (vmstat -nat 1 $taskNUM > "$RESULTS"/VmstatEI.csv) & 
   
    wait    
    mv "$SRC"/*thumb* "$TGT"
    if [ $? -gt 0 ]; then
        printf "\nCould not move "$SRC"/*thumb* to "$TGT"\n"
    fi;
}


