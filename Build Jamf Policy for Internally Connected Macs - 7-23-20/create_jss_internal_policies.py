from function_jamf_api_get import jamf_api_get
from function_gather_username_and_password_for_jamf import gather_username_and_password_for_jamf
from function_user_choice_from_list import user_choice_from_list
import requests
from requests.auth import HTTPBasicAuth

import xml.etree.ElementTree as ET

# Gather username and password
username, password = gather_username_and_password_for_jamf()

# Grab all packages
packages_response = jamf_api_get(username, password, "packages")

# Prompt user for package choice
packages = []
for package in packages_response["packages"]:
    packages.append(package['name'])

package_choice_index, package_name = user_choice_from_list(packages)

package_id = packages_response["packages"][int(package_choice_index)]['id']

# Print out choice
print("*******\nYou chose {} with package ID of {}".format(
    package_name, packages_response["packages"][int(package_choice_index)]['id']))

# Prompt user for Policy Display Name
policy_name = input(
    "*******\nPolicy Display Name (\"- Internal \" suffix will be added automatically): ")

# Verify Choices before Creating.
verify = input(
    "*******\nCONFIRM:\n Policy titles:\n    {} - Internal East\n    {} - Internal West\nPackage:\n    {}\n\nWould you like to create the two policies with selected package? (y/n): ".format(policy_name, policy_name, package_name))

if verify.lower() == "y" or verify.lower() == "yes":
    pass
else:
    print("Not adding policies. Exiting")
    exit()


print("*******\n Creating...")

url = "https://jss.$orgName.net:8443/JSSResource/policies/id/0"

# Dynamically set <name> to policy_name, <package><id> to package_id, and <packages><name> to package_name
east_payload = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<policy>\n    <general>\n        <name>{} - Internal East</name>\n        <enabled>false</enabled>\n        <trigger>EVENT</trigger>\n        <trigger_checkin>false</trigger_checkin>\n        <trigger_enrollment_complete>false</trigger_enrollment_complete>\n        <trigger_login>false</trigger_login>\n        <trigger_logout>false</trigger_logout>\n        <trigger_network_state_changed>false</trigger_network_state_changed>\n        <trigger_startup>false</trigger_startup>\n        <trigger_other/>\n        <frequency>Once per computer</frequency>\n        <location_user_only>false</location_user_only>\n       $TARGET_DRIVE        <offline>false</offline>\n        <category>\n            <id>-1</id>\n            <name>No category assigned</name>\n        </category>\n        <override_default_settings>\n            $TARGET_DRIVE            <distribution_point/>\n            <force_afp_smb>false</force_afp_smb>\n            <sus>default</sus>\n            <netboot_server>current</netboot_server>\n        </override_default_settings>\n        <site>\n            <id>-1</id>\n            <name>None</name>\n        </site>\n    </general>\n    <scope>\n        <all_computers>false</all_computers>\n        <computers/>\n        <computer_groups/>\n        <buildings/>\n        <departments/>\n        <limit_to_users>\n            <user_groups/>\n        </limit_to_users>\n        <limitations>\n            <users/>\n            <user_groups/>\n            <network_segments>\n                 $NETWORK_SEGMENTS </network_segments>\n            <ibeacons/>\n        </exclusions>\n    </scope>\n    <package_configuration>\n        <packages>\n            <size>1</size>\n            <package>\n                <id>{}</id>\n                <name>{}</name>\n                <action>Install</action>\n                <fut>false</fut>\n                <feu>false</feu>\n                <update_autorun>false</update_autorun>\n            </package>\n        </packages>\n    </package_configuration>\n    <reboot>\n        <message>This computer will restart in 5 minutes. Please save anything you are working on and log out by choosing Log Out from the bottom of the Apple menu.</message>\n        <startup_disk>Current Startup Disk</startup_disk>\n        <specify_startup/>\n        <no_user_logged_in>Do not restart</no_user_logged_in>\n        <user_logged_in>Do not restart</user_logged_in>\n        <minutes_until_reboot>5</minutes_until_reboot>\n        <start_reboot_timer_immediately>false</start_reboot_timer_immediately>\n        <file_vault_2_reboot>false</file_vault_2_reboot>\n    </reboot>\n    <maintenance>\n        <recon>true</recon>\n        <reset_name>false</reset_name>\n        <install_all_cached_packages>false</install_all_cached_packages>\n        <heal>false</heal>\n        <prebindings>false</prebindings>\n        <permissions>false</permissions>\n        <byhost>false</byhost>\n        <system_cache>false</system_cache>\n        <user_cache>false</user_cache>\n        <verify>false</verify>\n    </maintenance>\n</policy>".format(
    policy_name, package_id, package_name)
west_payload = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<policy>\n    <general>\n        <name>{} - Internal West</name>\n        <enabled>false</enabled>\n        <trigger>EVENT</trigger>\n        <trigger_checkin>false</trigger_checkin>\n        <trigger_enrollment_complete>false</trigger_enrollment_complete>\n        <trigger_login>false</trigger_login>\n        <trigger_logout>false</trigger_logout>\n        <trigger_network_state_changed>false</trigger_network_state_changed>\n        <trigger_startup>false</trigger_startup>\n        <trigger_other/>\n        <frequency>Once per computer</frequency>\n        <location_user_only>false</location_user_only>\n        $TARGET_DRIVE        <offline>false</offline>\n        <category>\n            <id>-1</id>\n            <name>No category assigned</name>\n        </category>\n        <override_default_settings>\n            $TARGET_DRIVE            <distribution_point/>\n            <force_afp_smb>false</force_afp_smb>\n            <sus>default</sus>\n            <netboot_server>current</netboot_server>\n        </override_default_settings>\n        <site>\n            <id>-1</id>\n            <name>None</name>\n        </site>\n    </general>\n    <scope>\n        <all_computers>false</all_computers>\n        <computers/>\n        <computer_groups/>\n        <buildings/>\n        <departments/>\n        <limit_to_users>\n            <user_groups/>\n        </limit_to_users>\n        <limitations>\n            <users/>\n            <user_groups/>\n                        <ibeacons/>\n        </limitations>\n        <exclusions>\n            <computers/>\n            <computer_groups/>\n            <buildings/>\n            <departments/>\n            <users/>\n            <user_groups/>\n            $NETWORK_SEGMENTS            <ibeacons/>\n        </exclusions>\n    </scope>\n    <package_configuration>\n        <packages>\n            <size>1</size>\n            <package>\n                <id>{}</id>\n                <name>{}</name>\n                <action>Install</action>\n                <fut>false</fut>\n                <feu>false</feu>\n                <update_autorun>false</update_autorun>\n            </package>\n        </packages>\n    </package_configuration>\n    <reboot>\n        <message>This computer will restart in 5 minutes. Please save anything you are working on and log out by choosing Log Out from the bottom of the Apple menu.</message>\n        <startup_disk>Current Startup Disk</startup_disk>\n        <specify_startup/>\n        <no_user_logged_in>Do not restart</no_user_logged_in>\n        <user_logged_in>Do not restart</user_logged_in>\n        <minutes_until_reboot>5</minutes_until_reboot>\n        <start_reboot_timer_immediately>false</start_reboot_timer_immediately>\n        <file_vault_2_reboot>false</file_vault_2_reboot>\n    </reboot>\n    <maintenance>\n        <recon>true</recon>\n        <reset_name>false</reset_name>\n        <install_all_cached_packages>false</install_all_cached_packages>\n        <heal>false</heal>\n        <prebindings>false</prebindings>\n        <permissions>false</permissions>\n        <byhost>false</byhost>\n        <system_cache>false</system_cache>\n        <user_cache>false</user_cache>\n        <verify>false</verify>\n    </maintenance>\n</policy>".format(
    policy_name, package_id, package_name)

headers = {
    'Content-Type': 'application/xml'
}

east_response = requests.request(
    "POST", url, auth=HTTPBasicAuth(username, password), headers=headers, data=east_payload, verify="/Users/tim.arnold/Documents/GitHub/$orgName/Python_Scripts/Test_Files/self_signed.pem")
west_response = requests.request(
    "POST", url, auth=HTTPBasicAuth(username, password), headers=headers, data=west_payload, verify="/Users/tim.arnold/Documents/GitHub/$orgName/Python_Scripts/Test_Files/self_signed.pem")

east_root = ET.fromstring(east_response.text.encode('utf8'))
west_root = ET.fromstring(west_response.text.encode('utf8'))

# Report back the two policy names and new IDs
print("*******\nCreated:\n    \"{} - Internal East\" with policy ID {}\n    \"{} - Internal West\" with policy ID {}".format(
    policy_name, east_root[0].text, policy_name, west_root[0].text))


# Print Alert and Next Steps
print("*******")
print("ALERT: DO NOT PUT THE PACKAGE ON THE CLOUD DISTRIBUTION POINT")
print("*******\nNext Steps:\n    1. Assign a Category\n    2. Set a Trigger and Execution Frequency\n    3. Add a Scope\n    4. Enable the Policy\n*******\n\n")
