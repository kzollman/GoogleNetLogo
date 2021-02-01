#!/bin/bash




###########################################################################################
# These things need to be changed for each run
###########################################################################################

# Path to your nlogo file

NLMODELPATH=$(pwd)
# Name of the nlogo file
NLMODELNAME=SegregationExample.nlogo

# Experiment you want to run
# You may only pass one experiment, otherwise things go heywire.

BSEXP=experiment

###########################################################################################
# Change only first time you run it
###########################################################################################

NLLOCALPATH=$(pwd)
NLLOCALFILE=NetLogo-6.2.0-64.tgz
ELASTIBIN=/home/kzollman/.local/bin/elasticluster
ELASTISTORAGE=/home/kzollman/.elasticluster/storage
GCPSSH=/home/kzollman/.ssh/google_compute_engine

###########################################################################################
# These should not need to be changed
###########################################################################################

PWD=$(pwd)

RESUMEFILE=remote-resume.bash
RESUMEPATH=$PWD/RemoteScripts

$ELASTIBIN sftp slurm <<__EOF__
put $RESUMEPATH/$RESUMEFILE
__EOF__

# Unzip NetLogo, split the experiemnt and 
$ELASTIBIN ssh slurm <<__EOF__
bash $RESUMEFILE
mv Results.csv $BSEXP.csv
tar cvzf $BSEXP.tar.gz $BSEXP.csv *.out
__EOF__

$ELASTIBIN sftp slurm <<__EOF__
get $BSEXP.tar.gz
__EOF__

# Don't shut down if that last function had an error. 
if [ $? -eq 0 ]; then
	yes | $ELASTIBIN stop slurm 
else
	echo "An error in transfering result. CLUSTER IS STILL RUNNING\!\n"
fi




