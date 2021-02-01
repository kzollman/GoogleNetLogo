# Introduction

This is a bash script designed to make running netlogo simulations easy with Google Cloud computing.  The script takes an existing NetLogo file with a specified BehaviorSpace experiment. It starts a single multi-processor machine on google clound (using the command line tool). It then uploads everything it needs, starts the model in headless mode, and when the model is finished, downloads the results (table format) to your local machine, and shuts down the remote machine.

The script is designed to be fault tolerant in the following sense: if you lose your internet connection temporarily or your local computer crashes, the google machine will continue to run the simulations.  However, BE AWARE that if there is any error durring the script it will exist and will NOT shut down the google machine. So if the script exists on error, please be sure and shut down the google machine manually.  This can be done at: https://console.cloud.google.com  If you do not, the machine will continue to run and you will continue to be charged.  You've been warned.

There is a recovery script designed to help you recover from an interrupted simulation run.

# Stuff needed for the script

1. You must get an account with Google Cloud, including starting a project and enabling billing. My university has a contract with Google, so I had to go through a local process in order to do this. You can also create your own and bill it directly to you.  There were some advantages to going through my university, as I wasn't limited by google's size constraints on early users. On the other hand, new users sometimes get free credits from Google.  I'll leave it up to you to figure out the best way to do this.

2. If you haven't already, you also need to set up the command line SDK.  Here is list of guides for different operating systems. https://cloud.google.com/sdk/docs/quickstarts

3. Make sure that you have the 64-bit linux .tar.gz of NetLogo somewhere on your system.  If you don't you can download it from here: https://ccl.northwestern.edu/netlogo/download.shtml  The google computer will be 64-bit linux even in your local machine is running a different operating system or is 32-bit.  So be sure and download this particular version.

# Configuring the runmodel script

In the second section, change the three variables there to match what fits you
1. Set NLLOCALFILE to match the complete path of the .tar.gz for the Linux version of NetLogo stored on your local machine.
2. Set THREADS to match how large a machine you would like.  The script always boots a highcpu machine, but with the number of cores you choose.  
  * NOTE 1: The acceptable values for this are 1, 2, 4, 8, 16, 32, 64, and 96
  * NOTE 2: Depending on how many cores you chose, and features of your simulation, you may need to have NetLogo allocate more memory than it does by default. To do this you will need to edit the netlogo-headless.sh script inside of the NetLogo .tar.gz archive on your local machine.  There are many instructions for how to do this found on google.
  * In my experience NetLogo does not seem to be able to do more than 32 cores efficiently.  The usage on 64 and 96 cores was very low. Since it seemeed like I was paying for unused cores, I've been sticking with 32 core machines.  Your milage may vary.
3. Set GZONE to the appropriate Google region. Here is a guide https://cloud.google.com/compute/docs/regions-zones/


# Use

To use the script you will need to change the variables in the first section to match what simulations you want to run.
1. Set NLMODELPATH to match the path on the local machine to where your nlogo file is stored.  Note there is no closing /
2. Set NLMODELNAME to match the the name of your NetLogo model
3. Set BSEXP to match the names of the BehaviorSpace experiments you would like to run
.* If you only want to run one BehaviorSpace experiment, it still needs to be enclosed in parens.  So it should read "BSEXP=(Experiment)"
.* If you want to run multiple BehaviorSpace epxeriments, enclose them in parens with spaces in between.  "BSEXP=(Experiment1 Experiment2)"  If you pass multiple experiments to the script, it will run them sequentially, downloading the results after each run is completed.
4. Once you've done this, run the script from the command line.  The script must continue to execute until the simulation is done, so don't shut down your computer.


# The recovery script

The script resume.bash is used for when the virtual machine is running a job but for one reason or another the local script has stopped.  Please determine which behavior space experiment is currently running and alter the EXPERIMENT variable to match what experiment is running.  

Please alter the ID variable to match the ID number created for the google virtual machine.  Whent the virtual machine is created it is given a name "netlogo-vm-XXXX" where XXXX is a random number.  That random number is your id number and what you should put into the script.  You can find this ID number either from the output of the runmodel.bash script or from the google console which will give you the name of the currently running machine.
