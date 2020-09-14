#!/bin/bash

#####
# Configure ID Prefs to default to the SmartCard
# Tim Arnold
# 12/15/17
####
# Run Cocoa Dialog Install Check.sh as a before to this scripting
####

CD="/Library/Application Support/$orgName/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

#### Functions
function cdTransform() {
  ### pass in cocoaDialog output and it will set a variable $status as the result

  #Cut up the two positions
  local buttonPress
  buttonPress=$(echo "$1" | head -1)

  #Quit on Cancel
  if [ "$buttonPress" == "2" ]; then
  	echo "Cancel button was pressed."
  	exit 0
	fi
}



echo "Certificate Identification Preference: *******"
echo "Certificate Identification Preference: Starting ID Prefs Reset"
echo "Certificate Identification Preference: *******"
echo ""
echo "Removing all previous identites"
security set-identity-preference -s $orgURL1 -n
security set-identity-preference -s $orgURL2 -n
security set-identity-preference -s $orgURL3 -n
security set-identity-preference -s $orgURL4 -n
security set-identity-preference -s $orgURL5 -n
security set-identity-preference -s $orgURL6 -n
security set-identity-preference -s $orgURL7 -n
security set-identity-preference -s $orgURL8 -n
security set-identity-preference -s $orgURL9 -n
security set-identity-preference -s $orgURL10 -n

echo ""
echo "Adding ID Prefs"

#Check if a SmartCard is plugged in
#Disabling cryptotoken kit disables '$security list-smartcards'
#Using find-identity with a grep on ',' since all of our user accounts are listed as Last Name, First Name
#All Machine and JAMF Certificates do not contain the ','
smartCardStatus=$(security find-identity -v | grep ,)
smartCardInserted=0

while [[ $smartCardInserted == "0" ]]; do
  if [[ "$smartCardStatus" == "" ]]; then
    echo "Certificate Identification Preference: SmartCard Not Found"
    insertSCPrompt=$("$CD" msgbox --float --no-show \
    --title "$orgName SmartCard ID Preferences" \
    --text "Please Insert Your SmartCard and Click OK" \
    --button1 "Ok" --button2 "Cancel")
    cdTransform "$insertSCPrompt"
    smartCardStatus=$(security find-identity -v | grep ,)
  else
    echo "Certificate Identification Preference: SmartCard Found: $smartCardStatus"
    smartCardInserted=1
  fi
done


#Gather First identity
firstIdentity=$(security find-identity -v | grep "1)" | cut -d "\"" -f2)
echo "Certificate Identification Preference: First Identity found is : $firstIdentity"

#Gather SHA1 of first Identity
sha1Hash=$(security find-certificate -c "$firstIdentity" -Z | grep "SHA-1 hash:" | cut -d ":" -f "2" | xargs)
echo "Certificate Identification Preference: SHA1 Hash Found: $sha1Hash"

#Use SHA1 to set Identity Preference
security set-identity-preference -Z "$sha1Hash" -s $orgURL1
security set-identity-preference -Z "$sha1Hash" -s $orgURL2
security set-identity-preference -Z "$sha1Hash" -s $orgURL3
security set-identity-preference -Z "$sha1Hash" -s $orgURL4
security set-identity-preference -Z "$sha1Hash" -s $orgURL5
security set-identity-preference -Z "$sha1Hash" -s $orgURL6
security set-identity-preference -Z "$sha1Hash" -s $orgURL7
security set-identity-preference -Z "$sha1Hash" -s $orgURL8
security set-identity-preference -Z "$sha1Hash" -s $orgURL9
security set-identity-preference -Z "$sha1Hash" -s $orgURL10

#Check ID preference
idPrefCheck=$(security get-identity-preference -s *.$orgName.gov &>/dev/null ; echo $?)
if [[ $idPrefCheck == "0" ]]; then
  echo "Certificate Identification Preference: *.$orgName.gov ID Pref set Properly."
else
  echo "Certificate Identification Preference: *.$orgName.gov ID Pref not set properly."
fi

#######
# Revoke id prefs
# security set-identity-preference -n -s *.$orgName.gov
