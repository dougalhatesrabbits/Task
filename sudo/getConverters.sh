#!/bin/bash

# Author: David Brooke for Third Light
#
# Date: 25.5.2018
#
# Original Version: 1.0
#
# Functionality: To test the deployment of 3 freely available image processing converter tools.
#                This is a supplement to the Test harness "callTask.sh" 
#
#                This standalone script checks for the installation of:
#
#                1. ImageMagick 
#                2. GraphicsMagick
#                3. ExactImage
#
#                and installs them if necessary. It also checks the pre-requisites of the machine 
#                to ensure it can run and maintan the latest versions of the software.
#
#                Root or Sudo privileges are required.
#
# Usage:         Command line call = sudo ./getConverters.sh.sh 
#
# =================
# Version history
# =================
# 1.1
# 23.5.2018
# David Brooke
# Added logging.
# -----------------

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HERE"
if [ $? -gt 0 ]; then
        printf "\nCould not cd to "$HERE"\n"
fi

# Debug mode

#if [ "$1"="-d" ]; then
 
#  set -xv

#else 
 
#   set +

#fi

#Logging
LOG="$HERE/logConverters.log"
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3 RETURN 
#exec 1>"$LOG" 2>&1
clear
printf "\n\e[37m$(date) \t$0 \e[1m\e[32mStart...\e[0m\n" | tee -i "$LOG"
printf "\n\e[37mWriting system prereqs to log:\e[0m\n$LOG\n" | tee -ai "$LOG"
printf "\n\e[37mDebian codename: \e[0m$(lsb_release -c | cut -d':' -f2)\n" | tee -ai "$LOG"
printf "\n\e[37mVersion: \e[0m$(uname -a | cut -d' ' -f3)\n" | tee "$LOG"
printf "\e[37m$(uname -a)\e[0m\n" | tee "$LOG"
printf "\nTasksel list\n-------------\e[37m\n$(tasksel --list-task)\n" | tee -ai "$LOG"
printf "\e[0m\nRepo Sources\n-------------\e[37m\n"

grep 'deb http://ftp.uk.debian.org/debian/ stretch main contrib non-free' \
    /etc/apt/sources.list | tee -ai "$LOG"
if [ $? gt 0 ]; then
	printf "\nStretch stable release repo not present...adding to /etc/apt/sources.list\n"
	printf "\n" >> /etc/apt/sources.list
	printf "deb http://ftp.uk.debian.org/debian/ stretch main contrib non-free\n" >> /etc/apt/sources.list
fi

grep 'deb http://security.debian.org/debian-security stretch/updates main contrib non-free' \
    /etc/apt/sources.list | tee -ai "$LOG"
if [ $? gt 0 ]; then
	printf "\nStretch stable updates repo not present...adding to /etc/apt/sources.list\n"
	printf "\n" >> /etc/apt/sources.list
	printf "ddeb http://security.debian.org/debian-security stretch/updates main contrib non-free\n" >> /etc/apt/sources.list
fi

printf "\n\e[0mNetwork status\n--------------\e[37m\n" | tee -ai "$LOG"
ifconfig | tee "$LOG"

apt-get -qq update | tee -ai "$LOG"
#apt-get -qq upgrade | tee "$LOG"

toolList="exactimage graphicsmagick imagemagick"

for tool in $toolList; do
    if [ $(dpkg-query -W -f='${Status}' $tool 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        printf "\n\e[31minstalling \e[0m$tool\n" | tee -ai "$LOG"
        apt-get -qq --yes --force-yes install $tool 
    else
        printf "\e[0m$tool \e[33malready installed\e[0m\n" | tee -ai "$LOG"
    fi
done

ulimit -a > "$HERE"/userLimits.txt &&
awk -F" " '{print $(NF-1), $NF}' "$HERE"/userLimits.txt > "$HERE"/uLimits.txt

systemctl -a > "$HERE/SystemList.txt"
systemctl list-unit-files > "$HERE/SystemUnits.txt"

printf "\e[37m\n$(date) \e[0m\t$0 \e[1m\e[32mDone!\e[0m\n"  | tee -ai "$LOG"
exit 0
