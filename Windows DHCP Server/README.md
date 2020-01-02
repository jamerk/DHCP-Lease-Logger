# Windows DHCP Lease Logger
A pair of scripts for logging MAC, hostname, and IP from a Windows DHCP Server to a MySQL DB on a Linux server.<br>
There are two scripts, one (getwinleases.sh) logs into the Windows DHCP Server via SSH and uses PowerShell to export the DHCP leases to a CSV and copy it to your Linux server that the scripts are running on then the second script (logwinleases.sh) cleans up the data in the CSV and imports it to your database running on the same Linux server.<br><br>
First, if you do not have a Linux server FEAR NOT! I made a PowerShell version that uses Microsoft SQL as the Database. Find it here: https://github.com/ITGoon/WinDHCPLeaseLogger <br><br>
## Setup
First we need to setup OpenSSH Server on the Windows DHCP Server, it's a little tedious but you can use Microsoft's instructions found here: https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-6<br>
Refer to the section labeled 'Set up on a Windows computer', when you're done go to Services and set the 'OpenSSH SSH Server' service to Automatic (I found mine was set to manual). Also be sure to allow Port TCP/22 on your Windows Firewall if it is in use.<br><br>
