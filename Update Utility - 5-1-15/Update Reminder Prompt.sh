#!/bin/bash

#############
## Title: Update Reminder Prompt
## Description: This script will give the customer a pre install prompt to close a specific program, then have a prompt during installation, then have a prompt when installation is complete.
##
## Author: Tim Arnold
## Date: 3/23/15
## Updated: 5/1/15
##
#############

#####Manually Set Variables#####
#Set in Script parameters
Date=$4
Trigger=UpdateTrigger
Timeout=14400
#####End Manually Set Variables#####


#####File Locations#####
CD="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoaDialog"
#####End File Locations#####

#####Variable Gathering #####
#We need to read/set these Variables before the prompts so that the variable load properly.

#Check for updates that require a restart and ones that do not.
RestartRequired=`softwareupdate -l | grep restart | grep -v '\*' | cut -d , -f 1`

##This changes the prompt text below to say if restart is needed or not. (Trailing space after the "not" is needed to make message line up properly.
if [ "$RestartRequired" == "" ]; then
    RestartNeeded="not "
    echo "Restart is not needed."
else
	RestartNeeded=""
	echo "Restart is needed."
fi
#####End Variable Gathering


#####Message shown to customer######
#Pre Prompt
Title="$orgName Update"
Text="Updates are available. Please choose one of the following: "
InformativeText="Install - Installs updates now. Please save and close all work.
Postpone - Stops the installation from running. You may pospone this installation until $Date.
Self Service - Opens Self Service Manager so you can manually install the updates at your convenience.
Your computer will "$RestartNeeded"need to restart."

#Post Prompt
PostTitle="$orgName Update"
PostText="All updates have been installed."
PostInformativeText="Thank you for keeping your computer up to date."
#####End Message shown to Customer#####

#Run Updates Function
fRunUpdates ()
{
    /usr/sbin/jamf policy -trigger "$Trigger"
    JamfPID=$(echo "$!")
    wait $JamfPID
    echo "Trigger Completed fully, returning to Reminder Prompt."
    pkill -i CocoaDialog

    POSTPROMPT=$("$CD" msgbox  --title "$PostTitle" \
        --text "$PostText" \
        --informative-text "$PostInformativeText" \
        --float --icon stop --timeout 900 --button1 "Ok")

    if [ "$POSTPROMPT" == "1" ]; then
            /bin/echo "User selected OK. Installation Complete and Verified."
    elif [ "$POSTPROMPT" == "0" ]; then
    	/bin/echo "Prompt timed out, installation successful."
    fi

    exit 0
}


###############Do not modify below this line##############

User=$(/usr/bin/who | /usr/bin/grep console | /usr/bin/cut -d " " -f 1)
echo "Variable User is $User"

if [ -z "$User" ]; then
	echo "No User Logged In, installing updates now."
	/usr/sbin/jamf policy -trigger "$Trigger"
    JamfPID=$(echo "$!")
    wait $JamfPID
    echo "Trigger Completed fully, returning to Reminder Prompt."
    pkill -i CocoaDialog
    echo "Killed AnyRemaining CocoaDialog windows. Installation successful."
	exit -0
fi

PROMPT=$("$CD" msgbox  --title "$Title" \
        --text "$Text" \
        --informative-text "$InformativeText" \
        --float --icon stop --timeout "$Timeout" --button1 "Install" --button2 "Postpone" --button3 "Self Service")

if [ "$PROMPT" == "1" ]; then
            /bin/echo "User selected OK. Triggering Installation."
            fRunUpdates
    elif [ "$PROMPT" == "2" ]; then
		/bin/echo "User postponed the installation."
		exit -0
	elif [ "$PROMPT" == "3" ]; then
		/bin/echo "Opted to launch Self Service"
		open -a /Applications/Self\ Service.app 2> /dev/null
		exit -0
	elif [ "$PROMPT" == "0" ]; then
		/bin/echo "Prompt Timed out after "$Timeout" seconds."
		exit -0
fi
exit -0
