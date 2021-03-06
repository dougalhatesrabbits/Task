# Task
bash image processing

 _____          _        _ _ 
|_   _|        | |      | | |
  | | _ __  ___| |_ __ _| | |
  | || '_ \/ __| __/ _` | | |
 _| || | | \__ \ || (_| | | |
 \___/_| |_|___/\__\__,_|_|_|
==============================


1. Uncompress tarball task.tgz anywhere in say $HOME.

2. Contents. 

./log
./install.txt
./callTask.sh
./tgt
./lib/task.sh
./lib/getStats.sh
./lib/_getStats.sh
./results
./src
./sudo/getConverters.sh
./tmp

3. The /src, /tgt, results & /tmp files are created during untar but location/name can be configured later
in the callTasks.sh.

4. Preliminary setup by the getConverters.sh if required. Also check machine readiness.

5. logCall.log & logSummary.log get generated on each run and all errors are logged here. This location can be configured.

6. Comment/Uncomment function calls from main as required.

7. Global variables are in UPPER case and can be configured.

8. The test harness can be iterated for stress testing and obtaining temporal results.

9*. To run, simply use ./callTask.sh [[0-9]]

10 To test the different compile options provided by each converter tool, add these to the calling function in Main.
e.g. testIM "-resize $SIZE" 
This example has 1 option. Note the inverted commas.
Up to 3 options are provided for in the script but more can be added by editing the particular function.



Known issues
============

1. Top 
Commands can behave spuriously. This may be an overhead on the test harness caused by the length and number of iterations. 
The intervals are anticipated and not calculated.
These will need to change depending on the size of the mumber of files to be resized. 
This can be configured. An approxiamte algorithm is included in the code but can be overridden

2. Vmstat
This may be overhead to the test harness and can be removed.



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
