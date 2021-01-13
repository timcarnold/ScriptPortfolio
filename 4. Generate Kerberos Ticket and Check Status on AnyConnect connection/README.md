### Generate Kerberos Ticket and Check Status on AnyConnect connection
##### OnConnect_logon.sh
##### 11-17-17

An OnConnect Script triggered after Cisco AnyConnect esablished a connection.
We were experiencing intermittent Kerberos ticket generation. Our SmartCard Software provider (Centrify) stated they refresh Kerberos tickets when a network state change occurred, but that was very intermittent. 

Once triggered, this script would initiate a Kerberos ticket request via Centrify’s 'sctool' utility. Then read the output/exit code to identify what state the computer was in (Kerberos ticket issued successfully, Network connection not fully established, or SmartCard not available. It would attempt up to 10 times. 

If a kerberos ticket was issued successfully, the user would be prompted that they are now fully connected. This prompt was added because some users were seeing the Cisco AnyConnect gold lock and immediately attempting to connect to internal resources that required Kerberos. After the prompt, a Centrify Update Group Policy was started in the background. 

The script also logged directly to the system log for easy troubleshooting in the field. 

###### Sanitized:
orgName
