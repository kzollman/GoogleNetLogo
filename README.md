This project is a collection of shell scripts to assist in using Google Compute Engine cloud computing to run NetLogo BehaviorSpace and BehaviorSearch experiments.

Look at the README.md file in each subdirectory to figure out what the scripts do.  Right now there are two scripts.  BSpace-OneNode is for running BehaviorSpace experiment(s) on a single node purchases from Google Compute Engine.  BSpace-MultiNode is for running a single large BehaviorSpace experiment on a cluster of machines from GCE.  This later script breaks up the BehaviorSpace experiment into smaller chunks so they can be run in parallel.

I wrote all the scripts for my own use on my own machine. They may work for you as well, but no promises. Feel free to contact me with questions, I am happy to help.

One important warning: please always monitor your Google Cloud deployment. If the script crashes (or if I screwed something up) a machine may continue to run after the job is finished and you will continue to be charged for it.  These scripts are provided without any promises, so you're on your own if you accidentally rack up a bunch of charges from google.

For more information about NetLogo please look at https://ccl.northwestern.edu/netlogo/ and for Google Compute https://cloud.google.com/compute
