### Build Jamf Policy for Internally Connected Macs

##### create_jss_internal_policies.py

##### 7-23-20



This script automates the complex task of building the policies for internal only software deployment. We have 2 Internal distribution points (East and West US). These policies overrides default distribution point to the nearest Internal distribution point based upon network segmentation. 

First, The script pulls all package titles from the Jamf API and displays them in the command prompt. The admin responds with a corresponding index number of the desired package to deploy. 

Next the script requests the Policy name (standard naming convention is appended automatically).
The admin is then prompted to confirm choices. 

Once confirmed, the script will POST a response to the Jamf API to build the two needed policies. These polices will automatically set all relevant network segment for limitation and exclusions -and- add the package to the policy and set the override Distribution point.  

Finally, the admin will be prompted with the follow up steps and the IDs of the two policies created. 

###### Sanitized:
orgName
TARGET_DRIVE 
NETWORK_SEGMENTS
