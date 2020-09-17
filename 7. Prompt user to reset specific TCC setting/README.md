### Prompt user to reset specific TCC setting
##### ResetTCCforSpecificApplication.sh
##### 5-26-20

Prompts user to chooses an application to reset the TCC Settings.

Users are not Admins, users may not be able to modify “Security & Privacy” - “Privacy” (TCC) settings. This script is designed to be run from Self Service. 

First, the script queries the current user’s TCC.db - selecting all access clients. Creating a list of the Application Bundle in the database. Any known application bundle will be converted to the Application Name. If not a known application Bundle - the full app bundle is displayed. 
The user is now prompted with this list, the user can select any specific app - or they can select All. 
The selected app (or all)  is reset using the ‘tccutil reset.’
