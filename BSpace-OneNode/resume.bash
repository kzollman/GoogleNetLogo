#!/bin/bash

# This script is used to recover from a crashed runmodel.bash script.  You will need to edit this file to 
# match what you have in the runmodel.bash scrip. In addition you need to get your run id from somewhere. 
# This was printed to the standard out by the runmodel script. It is also the numbers in your machine name
# on google clould  (all machine names are "netlogo-vm-XXXX" where XXXX is your run id).

# This will only recover the experiment that was being performed at the time.  If you had a list of experiments
# running, you will have to restart the ones that have not yet started.

###########################################################################################
# These things need to be changed for each run
###########################################################################################


# Experiment you want to recover

EXPERIMENT=SearchBetaAssignCommonA

# ID for machine name

ID=23626

###########################################################################################
# Change only first time you run it
###########################################################################################


# This is your default google zone. Choose one close to you.
GZONE=us-east1-c


###########################################################################################
# These should not need to be changed
###########################################################################################

GMACHINENAME=netlogo-vm-$ID
OUTFILE=$EXPERIMENT-table.csv
DONEFILE=$EXPERIMENT-done

if ! gcloud compute ssh $GMACHINENAME --zone="$GZONE" --command "test -e $DONEFILE > /dev/null 2>&1"; then
	printf "\033[1mExperiment Still Running, monitoring...\033[0m\n"
	while true; do
		LINENUM=$(gcloud compute ssh $GMACHINENAME --zone="$GZONE" --command "wc -l < $OUTFILE")
		FINISHED=$(( $LINENUM - 7 ))
		if (($FINISHED < 0)); then
			FINISHED=0
		fi
		printf "\r\033[1mFinished $FINISHED observations\033[0m"
		sleep 1m
		gcloud compute ssh $GMACHINENAME --zone="$GZONE" --command "test -e $DONEFILE > /dev/null 2>&1" && break
	done
fi

# Copy the output file back here

printf "\n\033[1mExperiment $EXPERIMENT finished. Copying results\033[0m"
gcloud compute scp $GMACHINENAME:$OUTFILE . --zone="$GZONE" --scp-flag=-C 

printf "\033[1mFinished resumed experiment, $EXPERIMENT. Shutting down machine $GMACHINENAME\033[0m\n"
# And shut down the virtual machine
gcloud compute instances delete "$GMACHINENAME" --zone="$GZONE" -q 


