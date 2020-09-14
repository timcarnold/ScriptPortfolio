#!/bin/bash

###
# Title: Pre-installation Script
# Pre-installation Script to close the program and then run a CD dialog during the Install
# Author: Tim Arnold
# Date: 3/24/15
# Updated: 5/1/15
###

CD="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoaDialog"

##Set Software name in Policy Parameter
SoftwareName=$4


#Install Progress Bar
ProgressBarTitle="$orgName Updates Installing"
ProgressBarText="Installing "$4""

################### Do not change below this line ##############################
/bin/echo "killing any previous CocoaDialog windows"
pkill -i CocoaDialog

/bin/echo "Quitting "$4""
pkill -i "$4"

if [ -z "$User" ]; then
	echo "No User Logged In, installing updates now."
else
	/bin/echo "Creating Progress Bar"
	/bin/rm -f /tmp/hpipe
	/usr/bin/mkfifo /tmp/hpipe

	/bin/echo "Putting progress bar on screen."
	# Create background to pass installation through pipe
	"$CD" progressbar --indeterminate --title "$ProgressBarTitle" --text "$ProgressBarText" < /tmp/hpipe &
	exec 3<> /tmp/hpipe
	echo -n . >&3
fi

#Sleeping until next policy kills window
sleep 3600 &
