#!/bin/bash

# SmartCard_Setup_Yosemite.sh 5/22/2015
# This script enables local PIV login for the entered user account.
# Questions the user for their LAN ID and then queries DSCL for the SmartCard Number
# Creates the User account with information gathered.
#
# Run this script with Cocoa Dialog.

directoryService="/Active Directory/$orgName/All Domains/"
promptUserReturn="1"

function promptUser() {

	CD="/Applications/Utilities/CocoaDialog.app/Contents/MacOS/CocoaDialog"
	rv=`$CD standard-inputbox \
	--width "500" \
	--title "$orgName Account Creator" \
	--icon "gear" \
	--informative-text "Please enter the AD username you woud like to use to log into this Mac:" \
	--no-newline --float`

	button=$(echo $rv | awk '{ print $1 }')
	shortName=$(echo $rv | awk '{ print $2 }')

	if [ "$button" == "1" ]; then
		echo "User said OK"
	elif [ "$button" == "2" ]; then
		echo "Canceling"
		exit 0
	fi

	# Check if the provided name exists in AD
	dirCheck=$(dscl "$directoryService" -read "Users/$shortName")
	if [ "$dirCheck" == "" ]; then
		promptUserReturn="1"
	else
		promptUserReturn="0"
	fi
}


# Prompt the user until they enter a username from AD
while [ "$promptUserReturn" = "1" ]
do
	promptUser
done

# Read RealName and UPN from AD
realName=$(dscl "$directoryService" -read "Users/$shortName" RealName | tail -1 | sed -e 's/^[ \t]*//')
upn=$(dscl "$directoryService" -read "Users/$shortName" dsAttrTypeNative:userPrincipalName | awk 'BEGIN {FS=": "} {print $2}')

# Generate a random password the user will not know
passwd=$(uuidgen)

sleep 10

# Create local user account
dscl . create /Users/"$shortName"
dscl . create /Users/"$shortName" UserShell /bin/bash
dscl . create /Users/"$shortName" RealName "$realName"
if [ -f /var/uid ]; then
	uid=$(cat /var/uid)
	dscl . create /Users/"$shortName" UniqueID "$uid"
	uid=$((uid + 1))
	rm /var/uid
	echo "$uid" > /var/uid
else
	uid=603
	dscl . create /Users/"$shortName" UniqueID "$uid"
	uid=$((uid + 1))
	echo "$uid" > /var/uid
fi

dscl . create /Users/"$shortName" PrimaryGroupID 20
dscl . create /Users/"$shortName" NFSHomeDirectory /Users/"$shortName"
dscl . create /Users/"$shortName" "dsAttrTypeNative:userPrincipalName" "$upn"
dscl . passwd /Users/"$shortName" "$passwd"

# Enable PIV support
security authorizationdb smartcard enable

sleep 5

# Display completion status
	rv=`$CD ok-msgbox \
	--width "500" \
	--title "$orgName Account Creator" \
	--icon "info" \
	--no-cancel \
	--text "User account created successfully!" --informative-text "You can now user your PIV card to log into this Mac." \
	--no-newline \
	--float`

exit 0
