### Add Printer Utility
##### AddPrinter_Centrify.sh
##### 10-13-17

Post Centrify - user’s could not search for printers via Bonjour.
Created this printer script to query print server, sort based upon building, then sort based upon selection

First, the script verified an internal network connection and valid kerberos ticket. It then put up an indeterminate progress bar to inform the user the process was running. While that was up, the print server was queried and every printer was iterated through to pull properly configured printers into an array. From that list a building list was generated and the user was prompted to select their building. Then a list of rooms in that selected building was generated and again the user was prompted to select their room. From that room a list of all printers was generated and again the user was prompted to select their desired printer. 

Once a printer was selected, the script attempts to locate a driver. The user was then prompted to select a driver from all drivers matching the printer model name. This list also included a ‘Generic PPD’ option and An option for the user to manually select a driver (If manually selected, the user was prompted with a file selector).

Finally another Progress bar was put up while the printer was setup. Additionally the requirement to use Kerberos auth was added (auth-info-required=negotiate). Then the user was prompted with a successful message. 

###### Sanitized:
printServer
orgName
