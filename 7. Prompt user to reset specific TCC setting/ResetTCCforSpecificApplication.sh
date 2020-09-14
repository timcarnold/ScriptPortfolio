#!/bin/bash

#######
# User chooses an application to reset the TCC Settings.
# Tim Arnold
# 5/26/20
# Seed from: https://www.macblog.org/post/reset-tcc-privacy/
#######

loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

#To get the user tim.arnold's tcc settings
allTccOptions=$(su -l $loggedInUser -c "sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db 'select client from access'" | sort -n | uniq)
echo "-------"
echo "-------"
echo "All Applications with TCC settings are:"
echo $allTccOptions
echo "-------"

#Human Readable Formatting of known bundle IDs
for appBundle in $allTccOptions; do
  # *) case removes anything before (and including) the first . - and replaced the . with spaces.
  case $appBundle in
      com.apple.Preview) option="Apple Preview"
          ;;
      com.apple.Terminal) option="Apple Terminal"
          ;;
      com.apple.TextEdit) option="Apple TextEdit"
          ;;
      com.cisco.Jabber) option="Cisco Jabber"
          ;;
      com.cisco.webex.Cisco-WebEx-Add-On) option="Cisco Webex Add-On"
          ;;
      com.cisco.webexmeetingsapp) option="Cisco Webex Meetings"
          ;;
      com.github.GitHubClient) option="GitHub Desktop"
          ;;
      com.github.atom) option="Atom"
          ;;
      com.jamfsoftware.JamfAdmin) option="Jamf Admin"
          ;;
      com.microsoft.Outlook) option="Microsoft Outlook"
          ;;
      com.microsoft.Powerpoint) option="Microsoft Powerpoint"
          ;;
      com.microsoft.rdc.macos) option="Microsoft Remote Desktop"
          ;;
      com.microsoft.teams) option="Microsoft Teams"
          ;;
      com.tinyspeck.slackmacgap) option="Slack"
          ;;
      com.webex.meetingmanager) option="Webex Meeting Manager"
          ;;
      us.zoom.xos) option="Zoom"
          ;;
      *) option=$(echo $appBundle | sed 's/^[^.]*.//g' | sed 's/\./\ /g')
          ;;
  esac
allTccChoices=$allTccChoices"\"$option\", "
done

#Adding "All" Option
formattedallTccChoices=$allTccChoices"\"All\""

#Prompting User
resetChoice=$(/usr/bin/osascript 2>/dev/null <<END
set theFruitChoices to {$formattedallTccChoices}
set theFavoriteFruit to choose from list theFruitChoices with prompt "For which app would you like the Privacy Decisions reset:"
theFavoriteFruit
END
)

echo "User chose $resetChoice"

#Decoding the BundleID from the Choice
case $resetChoice in
    "All") bundleID="All"
        ;;
    "Apple Preview") bundleID="com.apple.Preview"
        ;;
    "Apple Terminal") bundleID="com.apple.Terminal"
        ;;
    "Apple TextEdit") bundleID="com.apple.TextEdit"
        ;;
    "Cisco Jabber") bundleID="com.cisco.Jabber"
        ;;
    "Cisco Webex Add-On") bundleID="com.cisco.webex.Cisco-WebEx-Add-On"
        ;;
    "Cisco Webex Meetings") bundleID="com.cisco.webexmeetingsapp"
        ;;
    "GitHub Desktop") bundleID="com.github.GitHubClient"
        ;;
    "Atom") bundleID="com.github.atom"
        ;;
    "Jamf Admin") bundleID="com.jamfsoftware.JamfAdmin"
        ;;
    "Microsoft Outlook") bundleID="com.microsoft.Outlook"
        ;;
    "Microsoft Powerpoint") bundleID="com.microsoft.Powerpoint"
        ;;
    "Microsoft Remote Desktop") bundleID="com.microsoft.rdc.macos"
        ;;
    "Microsoft Teams") bundleID="com.microsoft.teams"
        ;;
    "Slack") bundleID="com.tinyspeck.slackmacgap"
        ;;
    "Webex Meeting Manager") bundleID="com.webex.meetingmanager"
        ;;
    "Zoom") bundleID="us.zoom.xos"
        ;;
    "false") echo "User Canceled Dialogue Window."
      echo "-------"
      exit 0
      ;;
    *) formattedResetChoice=$(echo $resetChoice | sed 's/\ /\./g')
      for appBundle in $allTccOptions; do
        cutAppBundle=$(echo $appBundle | sed 's/^[^.]*.//g')
        if [[ "$cutAppBundle" == "$formattedResetChoice" ]]; then
          #echo "Bundle ID Found: "$appBundle""
          bundleID="$appBundle"
        fi
      done
        ;;
esac

#
echo "-------"
echo "Resetting $bundleID"
if [[ "$bundleID" == "All" ]]; then
  su -l $loggedInUser -c "tccutil reset All"
else
  su -l $loggedInUser -c "tccutil reset All $bundleID"
fi

echo "-------"
exit 0
