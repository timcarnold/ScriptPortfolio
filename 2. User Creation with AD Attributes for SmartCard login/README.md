### User Creation with AD Attributes for SmartCard login
##### SmartCard_Setup_Yosemite.sh
##### 5-22-2015

At this time, we were using a device enforcement of SmartCard login - not account enforcement. Every device had to enforce login with SmartCards. Further, we were binding Mac to AD. So, each AD account still had a known  passwords associated with them. With these constraints, we needed a method of creating user accounts that did not enable the user to login with any known password. This script was placed in Jamf Self Service and triggered by the IT Tech during Mac Deployment. 

This script prompts user to type in an AD Username for the account. The script will then use the AD Bind to pull the AD RealName attribute and User Principal Name. It will then randomly generate a password and create an account with this information. 

This enabled a user to login with a SmartCard, but not a password (since it was unknown).

###### Sanitized:
orgName
