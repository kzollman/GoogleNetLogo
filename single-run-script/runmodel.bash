#!/bin/bash


# A VERY IMPORTANT WARNING: If this script fails because of an error, the google virtual machine
#  is not deleted.  This is by design, because there may be files that you want to recover or 
#  errors that you want to track down, or whatever.  But beware, this means that if something 
#  fails, you may be accuring charges for an idle machine. So always check the error status and 
#  manually delete any machines that might be still hanging around.



###########################################################################################
# These things need to be changed for each run
###########################################################################################

# Path to your nlogo file

NLMODELPATH=./
# Name of the nlogo file

NLMODELNAME=SegregationExample.nlogo

# Experiment you want to run
# This is an array that allows you to run multiple experiments sequentially, hence the "("s
# Example for more than one: BSEXP=(ConnectivitySizeAndReliability FineGrainedConnectivity)

BSEXP=(experiment)


###########################################################################################
# Change only first time you run it
###########################################################################################


# Location of the Netlogo tarball that you want to upload
# If you change this to a newer version, you should also update
# the remote command down in the script
NLLOCALFILE=NetLogo-6.1.0-64-zollman-local.tgz 

# Threads. This determines the size of the google machine you request
THREADS=32

# This is your default google zone. Choose one close to you.
GZONE=us-east1-c


###########################################################################################
# These should not need to be changed
###########################################################################################

# This sets up the machine name on google. We add random numbers to it so that we can
# have multiple instances of the script running and they don't bump into each other
ID=$RANDOM
GMACHINENAME=netlogo-vm-$ID
GMACHINETYPE=n1-highcpu-$THREADS

# Full path to model
NLMODELLOCAL=$NLMODELPATH/$NLMODELNAME

# Image for the gcompute machine
GIMAGE=https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/family/debian-9

set -e 


# Create the image
printf "\033[1mStarting google compute instance $GMACHINENAME\033[0m\n"
gcloud compute instances create "$GMACHINENAME" --machine-type="$GMACHINETYPE" --zone="$GZONE" --image-family="$GIMAGE" 
printf "\033[1mMachine created. Sleeping for 30s\033[0m\n"

# sleep for 30 seconds to make sure the machine is up and running
sleep 30s

# install java
printf "\033[1mInstalling java\033[0m\n"
gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "sudo apt-get update >aptget.log 2>&1; sudo apt-get install default-jre -y -qq >aptget.log 2>&1 "

printf "\033[1mCopying netlogo and model file\033[0m\n"
# Copy the local version of netlogo there, and uncompress it
gcloud compute scp "$NLLOCALFILE" "$GMACHINENAME": --zone="$GZONE"
gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "tar zxf $NLLOCALFILE" 

# Copy the model
gcloud compute scp "$NLMODELLOCAL" "$GMACHINENAME": --zone="$GZONE" --scp-flag=-C 

#Run all of the BehaviorSpace Experiments
for EXPERIMENT in "${BSEXP[@]}"
do
	printf "\033[1mRunning experiment $EXPERIMENT\033[0m\n"
	# I use a file "donefile" to mark when the simulation is finished on the google compute
        #  machinein order to handle broken internet connections.  


	# Run the model
	OUTFILE=$EXPERIMENT-table.csv
	STDOUTFILE=$EXPERIMENT-STDOUT
	STDERRFILE=$EXPERIMENT-STDERR
	DONEFILE=$EXPERIMENT-done
	SCRIPTNAME=run-$EXPERIMENT.sh

	# Modify this this next line if you are using a newer version
	# of NetLogo
	NLCOMMAND="NetLogo\\\\ 6.1.0/netlogo-headless.sh --model $NLMODELNAME --experiment $EXPERIMENT --threads $THREADS --table $OUTFILE"
	ENDCOMMAND="touch $DONEFILE"	

	# Remove preexisting "donefile" if it exists
	gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "rm -f $DONEFILE"

	#First we set up a short script to run the experiment, this
	# is what allows us to run it with nohup smoothly
	gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "echo $NLCOMMAND > $SCRIPTNAME"
	gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "echo $ENDCOMMAND >> $SCRIPTNAME"
	gcloud compute ssh "$GMACHINENAME" --zone="$GZONE" --command "nohup sh $SCRIPTNAME >$STDOUTFILE 2>$STDERRFILE &"

	# I do it this way to handle dropped internet connections

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

	# Copy the output file back here
	
	printf "\n\033[1mExperiment $EXPERIMENT finished. Copying results\033[0m"
	gcloud compute scp $GMACHINENAME:$OUTFILE . --zone="$GZONE" --scp-flag=-C 
done


printf "\033[1mFinished with all experiments. Shutting down machine $GMACHINENAME\033[0m\n"
# And shut down the virtual machine
gcloud compute instances delete "$GMACHINENAME" --zone="$GZONE" -q 

