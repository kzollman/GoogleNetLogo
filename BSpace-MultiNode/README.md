# Introduction

This is a bash script designed to make running netlogo simulations easy with Google Cloud computing.  This script is for taking very large behavior space experiments and breaking them up into smaller chunks and running them in parallel on a small cluster created in Google Cloud. The script takes an existing NetLogo file with a specified BehaviorSpace experiment. It fires up a cluster, uploads everything it needs, breaks up the experiment in small bite-size chunks, starts the chunks in headless mode, and when the model is finished, downloads the results (table format) to your local machine, and shuts down the remote machines.

When should you use this instead of the single run script?  This is for very large BehaviorSpace experiments that would ordinarily take too long when run as a single job. Use this script if you have a slow model or are searching a very large part of the parameter space. There is some significant overhead in starting up the cluster, so only use this if you really feel like you need to.

The script is designed to be fault tolerant in the following sense: if you lose your internet connection temporarily or your local computer crashes, the google machine will continue to run the simulations.  However, BE AWARE that if there is any error durring the script it will exist and will NOT shut down the google machine. So if the script exists on error, please be sure and shut down the google machine manually.  This can be done with the command "elasticluster stop slurm" or by logging into your google cloud console. If you do not, the machine will continue to run and you will continue to be charged.  You've been warned.

There is a recovery script designed to help you recover from an interrupted simulation run.  This will only recover if you have passed the "queueing" stage.  If it crashes before that, some jobs may not be run.

# Stuff needed for the script

1. You must get an account with Google Cloud, including starting a project and enabling billing. My university has a contract with Google, so I had to go through a local process in order to do this. You can also create your own account and bill it directly to you.  There were some advantages to going through my university, as I wasn't limited by google's size constraints on early users. On the other hand, new users sometimes get free credits from Google.  I'll leave it up to you to figure out the best way to do this.

2. If you haven't already, you also need to set up the command line SDK.  Here is list of guides for different operating systems. https://cloud.google.com/sdk/docs/quickstarts

3. Make sure that you have the 64-bit linux .tar.gz of NetLogo somewhere on your system.  If you don't you can download it from here: https://ccl.northwestern.edu/netlogo/download.shtml  The google computer will be 64-bit linux even in your local machine is running a different operating system or is 32-bit.  So be sure and download this particular version.

4. This script relies on Elasticluster to create the properly functioining cluster and to interface with it.  Please install Elasticluster, instructions here: https://elasticluster.readthedocs.io/en/latest/install.html  They recommend that you install it via Docker.  This WILL NOT work, as Docker introduces a bunch of headaches.  Please install via one of the other methods they recommend.  

5. You will also need to install ansible.  https://www.ansible.com/

# Configuring the runmodel script

Sorry, there is a lot of configuration to do.  I suppose I could probably automate some of it, but once it's configured once it's pretty easy to use. 

## Configure Elasticluster

1. You will need to get your google credentials by following these instructions: https://googlegenomics.readthedocs.io/en/latest/use_cases/setup_gridengine_cluster_on_compute_engine/index.html#index-obtaining-client-id-and-client-secrets

2. Edit the file "elasticluster.conf" in this directory to fit how you would like to use the cluser. Note: you do not need to mess with the default elasticluster configuration file. These scripts direct it to use the one in this directory.

3. In the section labeled \[cloud/google-cloud\], please insert the relevant information for google

4. You will need to generate ssh keys and put them somewhere.  Provide the correct links in this section as well

5. In the \[cluser/slurm\] section, you may want to change the "compute_nodes" value.  This is how many simultaneous computers are created as part of the cluster.  At a minimum it should be 2, otherwise you shouldn't bother with this method of running simulations.  It can be as large as you like.  But beware, the more of these you have, the faster the charges rack up.

6. You may want to change the type of computer you use for the "compute" nodes, this can be found in the \[clusters/slurm/compute\] section.  I use 32 core machines, which I've found to be the best for Netlogo simulations. You could try bigger or smaller if you like, but note if you change this because you'll need to make another change in a second.  I don't see a reason why you should need to change the "frontend" node.  It doesn't do all that much, and the small virtual computer seems to handle things just fine.  But feel free to change it if you like.

## Configure the startup and resume scripts

Make the following changes in both startupscript.bash and resume.bash

1. In the second section of this script you will need to point the script to where your NetLogo .tar.gz file is.  This is the variable NLLOCALPATH and NLLOCALFILE

2. You will need to tell it where the executable for elasticluster is, for me that was in my home directory under .local/bin

3. Also point this script to the "storage" directory for elasticluster. 

4. Finally, point this to where your ssh private key for Google is.  (You may have just generated this earlier.


## Change threads

You only need to do this if you altered the type of google machines used for the compute nodes when configuring elasticluster.  If you did that, you may need to change the number of threads used by NetLogo. This is done by editing the script RemoteScripts/jobtemplate.bash.  You just need to alter the "--threads" option in that script to be whatever you'd like it to be.  It should be less than or equal to the number of threads on a single machine.

# Use

Be forewarned, the startup takes a very long time.  (For me it's around 25-30 minutes, but it may be longer or shorter depending on a lot of things.) It's pretty chatty durring startup, so you shouldn't ever feel like things have hung up.  But don't expect it to be fast.

To use the script you will need to change the variables in the first section to match what simulations you want to run.
1. Set NLMODELPATH to match the path on the local machine to where your nlogo file is stored.  Note there is no closing /
2. Set NLMODELNAME to match the the name of your NetLogo model
3. Set BSEXP to match the names of the BehaviorSpace experiments you would like to run
4. Once you've done this, run the script from the command line.  The script must continue to execute until the simulation is done, so don't shut down your computer.


# The recovery script

The script resume.bash is used for when the virtual machine is running a job but for one reason or another the local script has stopped. Be sure and alter the relevant variables in this script to match your startup script before running it. It will try to pick up where the startup script left off, download the results, and shutdown the machines.

# What to expect

When everthing is done you will find a .tar.gz file in the working directory.  This contains all the results combined into a single file, as well as any error messages from any of the jobs.

# Credit where it is due

The script "split_nlogo" that takes a single behavior space experiment and breaks it into many different experiments was written by github user ahrenberg and is included with these scripts.  His script is distributed under the GPL-3.0 License
