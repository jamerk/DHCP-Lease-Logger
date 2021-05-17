# Windows DHCP Lease Logger
A pair of scripts for logging MAC, hostname, and IP from a Windows DHCP Server to a MySQL DB on a Linux server.<br>
There are two scripts, one (getwinleases.sh) logs into the Windows DHCP Server via SSH and uses PowerShell to export the DHCP leases to a CSV and copy it to your Linux server that the scripts are running on then the second script (winlogleases.sh) cleans up the data in the CSV and imports it to your database running on the same Linux server.<br><br>
First, if you do not have a Linux server FEAR NOT! I made a PowerShell version that uses Microsoft SQL as the Database. Find it here: https://github.com/jamerk/WinDHCPLeaseLogger <br><br>
These scripts have all been tested on a domain joined Windows 2012 R2 DHCP Server.<br><br>
## Setup
First we need to setup OpenSSH Server on the Windows DHCP Server, it's a little tedious but you can use Microsoft's instructions found here: https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-6<br>
Refer to the section labeled 'Set up on a Windows computer', when you're done go to Services and set the 'OpenSSH SSH Server' service to Automatic (I found mine was set to manual). Also be sure to allow Port TCP/22 on your Windows Firewall if it is in use.<br><br>
Next modify the variables in getwinleases.sh, the account that needs to be made in either Windows Active Directory or locally needs to be a Domain Admin or local admin and be in the DHCP Administrators group. Also be sure to update the two places in the PowerShell line for the FQDN of your Windows DHCP Server. You should also modify the scp line for where you'd like the CSV to be copied to on your Linux server.<br><br>
And finally the winlogleases.sh script needs to be modified to include your database login (See DHCP-Lease-Logger/README.md for database setup) as well as your windows domain name if you'd like to remove it from hostnames, otherwise comment out that line.<br>
## Credits
https://docs.microsoft.com/en-us/powershell/module/dhcpserver/get-dhcpserverv4lease?view=win10-ps<br>
https://social.technet.microsoft.com/Forums/en-US/8b11aab2-582b-4c07-9aaf-295a0940bd7e/export-dhcp-leases-to-readable-csv?forum=winserveripamdhcpdns<br>
https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-6<br>
https://stackoverflow.com/questions/37732/what-is-the-regex-pattern-for-datetime-2008-09-01-123545<br>
https://stackoverflow.com/questions/8857705/deleting-the-first-two-lines-of-a-file-using-bash-or-awk-or-sed-or-whatever<br>
https://stackoverflow.com/questions/7124778/how-to-match-anything-up-until-this-sequence-of-characters-in-a-regular-expres<br>
https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash<br>
https://stackoverflow.com/questions/45207167/iterate-over-and-replace-element-in-array<br><br>

## Issues
-> Some leases are randomly not in the CSV, I'm working on this... <br><br>
