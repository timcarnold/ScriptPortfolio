### Policy Update via LaunchDaemon
##### runPolicyFromDaemon.sh
##### 4-10-20

You cannot launch a ‘Jamf policy’ command directly from a Self Service policy. This script creates a LaunchDaemon to run a script to run Jamf Policy, when completed the script unloads the LaunchDaemon and removes itself.

First, the script will create a script to be triggered by a Jamf LaunchDaemon (/usr/local/bin/runJamfPolicy.sh). This sub-script prompts the user with a window showing the policy check is running. Then the sub-script will run a ‘jamf policy’ and ‘jamf recon.’  When finished, the sub-script will then prompt the user the policy run is completed, delete the sub-script, and remove and unload the Launch Daemon.

Next, the script set permissions for the sub-script. 
Finally, the script will call jamf scheduledTask to create a new LaunchDaemon to run the sub-script. This step is done to utilize the jamf framework so no additional PPPC settings need to be set. 
