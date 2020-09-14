#!/bin/bash

#######
# Search print server for printers, then sorts them based upon Printer information.
# Updated to setup printers using the Centrify smb printing.
# Tim Arnold
# 10/13/17
#######

printServer=$printServer
cocoaDialog="/Library/Application Support/$orgName/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

ProgressBarTitle="Printer Creation Wizard"


### Check internal network connection
if [[ $(ping -c2 $printServer &> /dev/null ; echo $?) != "0" ]]; then
  echo "Not connected to internal Network"
  "$cocoaDialog" ok-msgbox --title "$ProgressBarTitle" --text "ERROR: No internal network connection." --float --debug
  exit -404
fi

### Kerberos Check
if [[ $(klist 2>/dev/null | grep "krbtgt/orgName.GOV@orgName.GOV" &>/dev/null ; echo $?) != "0" ]]; then
  echo "No Kerberos Ticket Available."
  "$cocoaDialog" ok-msgbox --title "$ProgressBarTitle" --text "ERROR: No Kerberos Ticket." --float --debug
  exit -303
fi

### Check PPD settings

#if [[ $(cupsctl | grep Default) != "DefaultAuthType=Negotiate" ]]; then
#  echo "Kerberos not setup for printing"
#  cupsctl DefaultAuthType=Negotiate
#else
#  echo "Kerberos is setup in cups"
#fi

declare -a fullList
declare -a buildingList
declare -a modBuildingList
declare -a ppdPath
declare -a ppdName

echo "***** Starting Printer Script *****"
echo "*"
echo "*"

##### Building Printer List
/bin/echo "Creating Progress Bar"
/bin/rm -f /tmp/hpipe
/usr/bin/mkfifo /tmp/hpipe
/bin/echo "Putting progress bar on screen."

#Create background to pass installation through pipe
"$cocoaDialog" progressbar --indeterminate --title "$ProgressBarTitle" --text "Bulding Printer List" < /tmp/hpipe &
exec 3<> /tmp/hpipe
echo -n . >&3

while read -r list; do
  individualPrinter=$(echo "$list" | awk '{ print $1 }' | Grep "P-")
  countDash=$(tr -dc '-' <<<"$individualPrinter" | awk '{ print length; }')
  if [[ "$countDash" = 4 ]]; then
    fullList+=("$individualPrinter")
  fi
  #fullList+=("$individualPrinter")
done < <(smbutil view //$printServer)



echo "Full List Generated"
echo "*"
echo "*"
# echo "FullList is:"
# echo "${fullList[@]}"


for building in "${fullList[@]}"; do
  modBuilding=$( echo "$building" | cut -d "-" -f 2)
  buildingList+=("$modBuilding")
done

# echo "building list is:"
# echo "${buildingList[@]}"
# echo "***"

#Sort and Uniq list if in horizontal

modBuildingList=( $(printf "%s\n" "${buildingList[@]}" | sort | uniq ))

# echo "modBuildingList is:"
# echo "${modBuildingList[@]}"
echo "*"
echo "*"

/bin/echo "killing any previous CocoaDialog windows"
echo "*"
echo "*"
pkill -i CocoaDialog

promptBuilding=$("$cocoaDialog" standard-dropdown --title "$ProgressBarTitle" --text "Choose Building:" --items "${modBuildingList[@]}" --string-output --float --debug )
choiceOne=$(echo "$promptBuilding" | head -1)
modPromptBuilding=$(echo "$promptBuilding" | tail -1)

# echo "promptBuilding is : $promptBuilding"
# echo "*"
# echo "*"

if [[ $choiceOne == "Cancel" ]]; then
  echo "User Cancelled"
  exit -0
fi

# echo "Building Choice is:"
# echo "$modPromptBuilding"
# echo "*"
# echo "*"

#Dialogue to build Room List
/bin/echo "Creating Progress Bar"
# /bin/rm -f /tmp/hpipe
# /usr/bin/mkfifo /tmp/hpipe

/bin/echo "Putting progress bar on screen."
# Create background to pass installation through pipe
"$cocoaDialog" progressbar --indeterminate --title "$ProgressBarTitle" --text "Bulding Room List in $modPromptBuilding" < /tmp/hpipe &
exec 3<> /tmp/hpipe
echo -n . >&3

for room in "${fullList[@]}"; do
  modRoom=$( echo "$room" | grep "$modPromptBuilding" | cut -d "-" -f 3)
  roomList+=("$modRoom")
done

modRoomList=( $(printf "%s\n" "${roomList[@]}" | sort | uniq ))

# echo "Room List is"
# echo "${modRoomList[@]}"

/bin/echo "killing any previous CocoaDialog windows"
pkill -i CocoaDialog

## Prompt Users For Room Selection
promptRoom=$("$cocoaDialog" standard-dropdown --title "$ProgressBarTitle" --text "Choose Room:" --items "${modRoomList[@]}" --string-output --float --debug )
choiceTwo=$(echo "$promptRoom" | head -1 )
modPromptRoom=$(echo "$promptRoom" | tail -1 )

if [[ $choiceTwo == "Cancel" ]]; then
  echo "User Cancelled"
  exit -0
fi

echo "Room Choice is:"
echo "$modPromptRoom"
echo "*"
echo "*"

#Dialogue to build Printer List
/bin/echo "Creating Progress Bar"
# /bin/rm -f /tmp/hpipe
# /usr/bin/mkfifo /tmp/hpipe

/bin/echo "Putting progress bar on screen."
# Create background to pass installation through pipe
"$cocoaDialog" progressbar --indeterminate --title "$ProgressBarTitle" --text "Bulding Printer List in room $modPromptRoom" < /tmp/hpipe &
exec 3<> /tmp/hpipe
echo -n . >&3

## Building list of Printers based off Building and Room Selection
for printer in "${fullList[@]}"; do
  modPrinters=$( echo "$printer" | grep "$modPromptBuilding" | grep "$modPromptRoom" | cut -d "-" -f 4,5,6)
  printersList+=("$modPrinters")
done

modPrintersList=( $(printf "%s\n" "${printersList[@]}" | sort | uniq ))



echo "Printers List is"
echo "${modPrintersList[@]}"


/bin/echo "killing any previous CocoaDialog windows"
pkill -i CocoaDialog

## Prompt Users For Printer Selection
promptPrinter=$("$cocoaDialog" standard-dropdown --title "$ProgressBarTitle" --text "Choose Printer:" --items "${modPrintersList[@]}" --string-output --float --debug )
choiceThree=$(echo "$promptPrinter" | head -1 )
modPromptPrinter=$(echo "$promptPrinter" | tail -1)

if [[ $choiceThree == "Cancel" ]]; then
  echo "User Cancelled"
  exit -0
fi

echo "Printer Choice is:"
echo "$modPromptPrinter"
echo "*"
echo "*"

##### Gather printer information #####
#Find Printer Model from Name
printerModel=$(echo "$modPromptPrinter" | cut -d "-" -f 2 )

echo "Printer Model is:"
echo "$printerModel"
echo "*"
echo "*"

# Find PPD in /Library/Printers/PPDs/Contents/Resources
while read -r ppd; do
  ppdPath+=("$ppd")
done < <(find /Library/Printers/PPDs/Contents/Resources/ -maxdepth 1 -name "*$printerModel*")

#ppdPath=$( find /Library/Printers/PPDs/Contents/Resources/ -maxdepth 1 -name "*$printerModel*" | sed -e "s/.*/'&'/" )
# find /Library/Printers/PPDs/Contents/Resources/ -maxdepth 1 -name "*775*" | sed -e "s/.*/'&'/"

for path in "${ppdPath[@]}"; do
  ppdBasename=$(basename "$path")
  ppdName+=("$ppdBasename")
done

#Prompt User to Select Printer Driver - add Generic PPD
promptDriver=$("$cocoaDialog" standard-dropdown --title "$ProgressBarTitle" --text "Choose Driver:" --items "${ppdName[@]}" "Generic PPD" "Manually Select Other Driver" --string-output --float --debug )

modPromptDriver=$(echo "$promptDriver" | tail -1 )
choiceFour=$(echo "$promptDriver" | head -1 )

if [[ $choiceFour == "Cancel" ]]; then
  echo "User Cancelled"
  exit -0
fi

echo "User Chose: "
echo "$modPromptDriver"
echo "*"
echo "*"

#Full path of Driver Search

if [[ $modPromptDriver == "Generic PPD" ]]; then
  echo "User Chose Generic PPD"
  echo "*"
  echo "*"
  driver="/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Resources/Generic.ppd"

elif [[ $modPromptDriver == "Manually Select Other Driver" ]]; then
  echo "User Chose to Choose other Driver"
  ppdSelect=$( "$cocoaDialog" fileselect --title "Select files" --text "Please select files" --with-directory "/Library/Printers/PPDs/Contents/Resources/")
  driver="$ppdSelect"
  echo "User chose: $ppdSelect"
  echo "*"
  echo "*"

else
  echo "User Chose Installed Driver"
  echo "*"
  echo "*"
  driver="/Library/Printers/PPDs/Contents/Resources/$modPromptDriver"
fi

echo "Driver location is:"
echo "$driver"
echo "*"
echo "*"

#Setting Up Printer:
echo "Setting Up Printer Loader bar.........."
echo "*"
echo "*"

/bin/echo "Creating Progress Bar"
# /bin/rm -f /tmp/hpipe
# /usr/bin/mkfifo /tmp/hpipe

/bin/echo "Putting progress bar on screen."
# Create background to pass installation through pipe
"$cocoaDialog" progressbar --indeterminate --title "$ProgressBarTitle" --text "Configuring Printer" < /tmp/hpipe &
exec 3<> /tmp/hpipe
echo -n . >&3

printerName="$modPromptPrinter"@"$modPromptBuilding"-"$modPromptRoom"
echo "$printerName"

#Add printer - real work happens here...
/usr/sbin/lpadmin -p "$modPromptPrinter"@"$modPromptBuilding"-"$modPromptRoom" -E -v "smb://$printServer.$orgName.gov/P-$modPromptBuilding-$modPromptRoom-$modPromptPrinter" -P "$driver"
/usr/sbin/lpadmin -p "$printerName" -o auth-info-required=negotiate

### Display Printer setup Done
echo "Printer Setup Done Dialogue box"
/bin/echo "killing any previous CocoaDialog windows"
pkill -i CocoaDialog

rv=$("$cocoaDialog" ok-msgbox --title "$ProgressBarTitle" --text "Printer Successfully Configured" --float ‑‑no‑cancel --debug)

if [ "$rv" == "1" ]; then
  echo "User said OK"
elif [ "$rv" == "2" ]; then
  echo "Canceling"
  exit
fi

exit -0

# ######################################### Useful Printer Commands
#
# #To find installed printer
# #ls /etc/cups/ppd/
#
# #Delete printer
# #/usr/sbin/lpadmin -x "printerName"
#
#
# #######
# #Future Improvements
# # fix if 3 dashes instead of 4: Added check to only add properly configured printers to the generated list.
#     #Parse CSV from PowerShell
#     #Download CSV First and check
# # Full Printer name when prompted
