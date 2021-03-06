### Update Utility
##### 5-1-15
##### 3 Scripts:
1. Update Reminder Prompt.sh
2. Update Force Prompt.sh
3. PreInstallation Script.sh

We needed a process to reliably update computers. Though, the organization had a Union that would inhibit us from forcing updates without prompting users.  So, I devised a two part update process. The first is a “Reminder Prompt” policy that will notify users when an update is pending. Second, on a set date the “Force Install” policy would prompt the user that updates are going to be force and then given a 5 minute grace period to save and close all work. 

There are three scripts in this process:
1. “Update Reminder Prompt.sh” triggers when an update is available and will inform the user. It also give the user 3 options - 1. Update now, 2. Open Self Service, 3. Postpone.  
If a user chose to update, then this script will call the custom trigger to run the installations. 
2. “PreInstallation Script.sh” runs before each update to verifiy the target application is closed and prompts the user the update is installing. 
3. “Update Force Prompt.sh” triggers when an update is to be forced. Gives the user 5 minutes to save and close all work. Then it will call the custom trigger to install updates. 

For example:
A Firefox 80.0.1 update is needed to be deployed. The 80.0.1 package would be created and tested. 
A Smart Group would be created to target all computers without the 80.0.1 update installed. 
When the update was to go live, a Firefox policy would be created, trigger set to Custom “UpdateTrigger”, 80.0.1 package is attached, “PreInstallation Script.sh” is attached to trigger before installation, and Scoped newly created Smart Group. 
The “Reminder Prompt” Policy would be edited to now include the created SmartGroup. Anytime a computer checks in - and is in the Smart Group - the prompt script would trigger.
On the Force Install date, the “Reminder Prompt” would have the Smart Group de-scoped and the “Force Install” Policy would be scoped to the Smart Group. Whenever a computer with a needed update checks in, the user will be prompted and the update installed. 

###### Sanitized:
orgName
