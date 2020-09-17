### Set Keychain ID preferences from SmartCard Hash
##### Reset_ID_Prefs.sh
##### 12-15-17

This script was built to be added to Jamf Self Service as an end user/IT Technician Utility. Logging was done to Jamf via echo.  

Built to reset ID Preferences of certain domains to the identity of an inserted SmartCard.
First it clears identity preferences for certain domains. Then will attempt to read a SmartCard, if no SmartCard is identified, then it will prompt the user to plug in a SmartCard. Once a SmartCard is identified, it will pull the identity  (we only had one, so I could pull the first identity), and then pull the certificate hash from that identity.
Then it will set the identity preference to that of the sha1 Hash. Finally, it will check if the setting was properly set and then logged. 

###### Sanitized:
orgName
orgURL (multiple)
