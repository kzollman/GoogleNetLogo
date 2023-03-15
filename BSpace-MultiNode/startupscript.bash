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

NLLOCALPATH=..
NLLOCALFILE=NetLogo-6.2.0-64.tgz
ELASTIBIN=/home/kzollman/.local/bin/elasticluster
ELASTISTORAGE=/home/kzollman/.elasticluster/storage
GCPSSH=/home/kzollman/.ssh/google_compute_engine

###########################################################################################
# These should not need to be changed
###########################################################################################

PWD=$(pwd)
CONFILE=$PWD/elasticluster.conf
JAVAYML=$PWD/java.yml


SPLITBINFILE=split_nlogo_experiment.py
SPLITBINPATH=$PWD/split_nlogo

SLURMJOBFILE=jobtemplate.bash
SLURMJOBPATH=$PWD/RemoteScripts

SCHEDFILE=scheduler.bash
SCHEDPATH=$PWD/RemoteScripts

set -e

$ELASTIBIN -c $CONFILE start slurm

# It looks like this is really the only way to do this cleanly.  It's anoying, because there should be
# and easy way to do it with elasticluster, but the way they tell you to do it doesn't work.
ansible-playbook --private-key=$GCPSSH --inventory=$ELASTISTORAGE/slurm.inventory --become --become-user=root $JAVAYML

$ELASTIBIN sftp slurm <<__EOF__
put $NLLOCALPATH/$NLLOCALFILE
put $NLMODELPATH/$NLMODELNAME
put $SPLITBINPATH/$SPLITBINFILE
put $SLURMJOBPATH/$SLURMJOBFILE
put $SCHEDPATH/$SCHEDFILE
__EOF__

# Unzip NetLogo, split the experiemnt and 
$ELASTIBIN ssh slurm <<__EOF__
tar zxvf $NLLOCALFILE
mkdir jobs
python $SPLITBINFILE --output_dir jobs --create_script $SLURMJOBFILE $NLMODELNAME $BSEXP
bash $SCHEDFILE
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




