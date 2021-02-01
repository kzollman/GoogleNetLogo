#!/bin/bash

RESULTFILE=Results.csv

#Got this from https://github.com/fearside/ProgressBar/
function ProgressBar {

	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done

	_fill=$(printf "%${_done}s")
	_empty=$(printf "%${_left}s")

	printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}

echo "This script resumes monitoring for jobs.  I do not check to be sure all jobs are submitted."


JOBS=(jobs/*.bash)

echo -e "\nWaiting for jobs to finish"

while true; do
	JOBSLEFT=$(squeue | wc -l)
	JOBSLEFT=$((JOBSLEFT - 1))
	ProgressBar $((${#JOBS[@]} - $JOBSLEFT)) ${#JOBS[@]}
	if [ $JOBSLEFT -eq 0 ]; then 
		break;
	fi
done

echo -e "\nCleaning up output files"

for FILE in *.out; do
        if [ $(wc -l < $FILE) -eq 2 ]; then
                rm $FILE
        fi
done


echo -e "\nCombining results into single CSV file."

CSVS=(*.csv)

head -n -7 ${CSVS[0]} > $RESULTFILE

for FILE in ${CSVS[@]}; do
	tail -n +8 $FILE >> $RESULTFILE
done

