#!/bin/bash


#####
##Title: Update Force Install Script
##Description: When a drop dead date is set, these updates will be force installed.
##By Tim Arnold
## Date: 3/23/15
## Updated: 5/1/15
#####

#Time (in seconds) to wait before forcing updates.
JHTimer="300"

Trigger=UpdateTrigger

#Jamf Helper & Cocoa Dialogue Location
JH="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
CD="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoaDialog"

#####Variable Gathering#####
#We need to read/set these Variables before the prompts so that the variable load properly.

#Check if user is logged in
User=$(/usr/bin/who | /usr/bin/grep console | /usr/bin/cut -d " " -f 1)
echo "Variable User is $User"

#Check for updates that require a restart and ones that do not.
RestartRequired=`softwareupdate -l | grep restart | grep -v '\*' | cut -d , -f 1`

##This changes the prompt text below to say if restart is needed or not. (Trailing space after not is needed to make message line up properly.
if [ "$RestartRequired" == "" ]; then
    RestartNeeded="not "
    echo "Restart is not needed."
else
	RestartNeeded=""
	echo "Restart is needed."
fi
#####End Variable Gathering#####

#####Text for prompts#####
#When the updates are forced, we are giving customers 5 minutes to save and close their work. I am using Jamf Helper since there is a visible countdown.
JHTitle="$orgName Updates"
JHDescription="Your Computer will now install Updates. Please save and close your work within 5 minutes. Your computer will "$RestartNeeded"need to restart."

#PostInstallation Prompt
PostTitle="$orgName Update"
PostText="All updates have been installed."
PostInformativeText=""
#####End Text for prompts#####

fRunUpdates ()
{
    /usr/sbin/jamf policy -trigger "$Trigger"
    JamfPID=$(echo "$!")
    wait $JamfPID
    echo "Trigger Completed fully, returning to Force Install Script."
    pkill -i CocoaDialog


    POSTPROMPT=$("$CD" msgbox  --title "$PostTitle" \
        --text "$PostText" \
        --informative-text "$PostInformativeText" \
        --float --icon stop --timeout 900 --button1 "Ok")

    if [ "$POSTPROMPT" == "1" ]; then
            /bin/echo "User selected OK. Installation Complete and Verified."
    elif [ "$POSTPROMPT" == "0" ]; then
	    /bin/echo "Prompt timed out, installation successful."
    else
	    echo "Exception occurred, exiting"
	    exit -1
    fi

    exit 0
}

#####Do not modify below#####
if [ -z "$User" ]; then
	echo "No User Logged In - Running Install."
	/usr/sbin/jamf policy -trigger "$Trigger"
	JamfPID=$(echo "$!")
    wait $JamfPID
    echo "Trigger Completed fully, returning to Force Install Script."
	pkill -i CocoaDialog
	exit -0
fi

"$JH" -windowType hud -alignDescription center -title "$JHTitle" -description "$JHDescription" -icon /Library/Application\ Support/$orgName/Icons/$orgName.png -lockHUD -startlaunchd -button1 "Install Now" -timeout "$JHTimer" -countdown
			fRunUpdates

if [ "$JH" == "1" ]; then
	echo "Customer clicked OK"
	fRunUpdates
elif [ "$JH" == "0" ]; then
    echo "Force Prompt timed out after $JHTimer seconds."
	fRunUpdates
else
	echo "Exception occurred, running Force Prompt."
	fRunUpdates
fi

exit -0
