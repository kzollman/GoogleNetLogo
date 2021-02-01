#!/bin/bash
#
#SBATCH --job-name=nlogo-{job}
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32

echo "JobID: {job}"
/home/kzollman/NetLogo\ 6.2.0/netlogo-headless.sh --model {model} --setup-file {setup} --table {csvfname} --threads 32
