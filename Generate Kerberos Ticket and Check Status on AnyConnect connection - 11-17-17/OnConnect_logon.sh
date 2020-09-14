#!/bin/bash

###
# Generate Kerberos Ticket and Check Status
# Written By: Tim Arnold
# 11-17-17
###
# Info: Script is runs as logged in user
# Utilizes CocoaDialog to inform the user that the Kerberos ticket has been successfully generated.
# Profile enabling scripting must be ran from the Head end (VPN Server)
# Script must be pushed from the Head End as well
###

logger "AnyConnect Kerberos Generation: -------------------"
logger "AnyConnect Kerberos Generation: Starting"
cocoaDialog="/Library/Application Support/$orgName/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

#Run command to generate Kerberos ticket
scCheck=0
scTry=1

while [[ $scCheck != "1" ]]; do
  if [[ $scTry == "10" ]]; then
    logger "AnyConnect Kerberos Generation: ERROR - Server unreachable after 10 attempts"
    exit -1
  fi

  scStatus=$(/usr/local/bin/sctool -k 2>&1)
  scExitCode="$?"
  logger "AnyConnect Kerberos Generation: Initializing Ticket - Attempt $scTry"
  logger "AnyConnect Kerberos Generation: sctool Exit Code $scExitCode"
  logger "AnyConnect Kerberos Generation: sctool Status - $scStatus "
  if [[ $scStatus == "Not connected to the AD domain.  Local challenge / response succeeded.: Server unreachable" ]]; then
    logger "AnyConnect Kerberos Generation: Delaying 5 seconds and re-trying sctool "
    #Cisco has not completed connection
    sleep 5
  elif [[ $scExitCode == "0" ]]; then
    scCheck=1
  elif [[ $scExitCode == "255" ]]; then
    logger "AnyConnect Kerberos Generation:SmartCard is not plugged in, please plug in SmartCard"
  fi
  scTry=$((scTry + 1))
done

#Check if tgt is there
kerbCheckStatus=$(klist 2>&1)
kerbCheckExitCode="$?"

if [[ $kerbCheckStatus == "klist: krb5_cc_get_principal: No credentials cache file found" ]]; then
  #In one specific instance of a ticket cache is misisng but ticket is present, the ticket generation will succeed but klist will report a failure.
  logger "AnyConnect Kerberos Generation: Sleep 1"
  sleep 1
  kerbCheckStatus=$(klist 2>&1)
  kerbCheckExitCode="$?"
fi

if [[ $kerbCheckExitCode == "0" ]]; then
  logger "AnyConnect Kerberos Generation: Success - Kerberos Ticket WAS generated"$orgName
  "$cocoaDialog" bubble --title "$orgName Kerberos Authentication" --text "You are now connected to the $orgName Network." --icon-file "/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app/Contents/Resources/vpngui.icns" &>/dev/null
else
  logger "AnyConnect Kerberos Generation: ERROR - Kerberos ticket was NOT generated"
  logger "AnyConnect Kerberos Generation: ERROR - klist Exit Code $kerbCheckExitCode"
  logger "AnyConnect Kerberos Generation: ERROR - klist Exit Status $kerbCheckStatus"
fi

logger "AnyConnect Kerberos Generation: Updating Group Policy"

#Centrify command to update group policy
adgpupdate
logger "AnyConnect Kerberos Generation: Group Policy Updated"

exit
