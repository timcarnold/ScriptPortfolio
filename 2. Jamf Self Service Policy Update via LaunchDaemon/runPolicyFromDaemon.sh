#!/bin/bash

#######
#Create a LaunchDaemon to run a script to run Jamf Policy, then the script unloads the LaunchDaemon and removes itself
# Original idea - brunerd - Joel Bruner - https://www.jamf.com/jamf-nation/discussions/10461/running-jamf-policy-via-self-service
# Tim Arnold - Modified to create LaunchDaemon via Jamf command AND to run script via jamf command to get around PPPC
# 4-10-20
#######

#unload if it exists for some reason
[ -e "/Library/LaunchDaemons/com.jamfsoftware.task.jamfPolicy.plist" ] && rm -f "/Library/LaunchDaemons/com.jamfsoftware.task.jamfPolicy.plist" 2>/dev/null
launchctl remove com.jamfsoftware.task.jamfPolicy.plist 2>/dev/null

#Create Script to run the policy command
cat << EOF > /usr/local/bin/runJamfPolicy.sh
#!/bin/bash

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

#time to wait between checks ensuring "jamf policy" has ended
sleepIntervalSeconds=10

#send to a log file and echo out
function logEcho {
#echo out to stdout and /var/log/jamf.log
echo "\$(date +'%a %b %d %H:%M:%S') \$(hostname | cut -d . -f1) \${myName:="\$(basename "\${0%%.*}")"}[\${myPID:=\$\$}]: \$@" | tee -a /var/log/jamf.log
}

"\$jamfHelper" -windowType hud -title "Configuration Check" \
-heading "Running Configuration Check" \
-description "Installing any missing software now..." \
-windowType utility&

#until the "jamf policy" is not found in the output of "ps auxww" sleep and keep checking
until [ -z "\$(ps auxww | grep [j]amf\ policy)" ]; do
    logEcho "Waiting jamf policy running, waiting \${sleepIntervalSeconds} seconds..."
    sleep \${sleepIntervalSeconds}
done

logEcho "All clear, running \"/usr/local/bin/jamf policy\""
/usr/local/bin/jamf policy
/usr/local/bin/jamf recon

logEcho "Finished. Exiting and Uninstalling."

"\$jamfHelper" -windowType hud -title "Configuration Check" \
-heading "Configuration Check Complete" \
-description "Please Refresh Self Service to Check Configuration Again" \
-windowType utility \
-button1 "Ok" \
-defaultButton 1

#delete this script
rm -f "\$0"

#erase the launchd file
rm -rf /Library/LaunchDaemons/com.jamfsoftware.task.jamfPolicy.plist

#remove the launchd by label name
launchctl remove com.jamfsoftware.task.jamfPolicy

EOF

#ensure correct ownership and mode
chmod ugo+rx,go-w "/usr/local/bin/runJamfPolicy.sh"

#Create and Start the LaunchDaemon
jamf scheduledTask -command "/usr/local/jamf/bin/jamf runScript -script runJamfPolicy.sh -path /usr/local/bin" \
-name jamfPolicy -runAtLoad true
