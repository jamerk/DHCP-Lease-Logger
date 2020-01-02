#!/usr/bin/expect -f

# Set the following variables after you setup OpenSSH
# on your windows dhcp server, see README.md for instructions
set username DOMAIN_OR_LOCAL_USER
set password A_SECURE_PASSWORD
set server ServerName

# Spawn an SSH session to connect to your windows DHCP Server
spawn ssh $username@$server
expect "*password:" {send "$password\r"}
expect "PS*" {send "Get-DhcpServerv4Scope -ComputerName ServerName.Your.Domain | Get-DhcpServerv4Lease -ComputerName ServerName.Your.Domain | select Hostname, ClientId, IPAddress, LeaseExpiryTime | Export-csv -path \"C:\exportdir\dhcpleases.csv\"\r"}
expect "PS*" {send "exit\r"}
expect eof
# Spawn a new bash session to copy the dhcp lease CSV from your windows dhcp server to your linux server with the database
spawn bash
expect "*#" {send "scp $username@$server:/exportdir/dhcpleases.csv /root/Device_Logger/\r"}
expect "*password:" {send "$password\r"}
expect "*#" {send "exit\r"}
expect eof
# Spawn one last bash session to clean up the CSV a little bit, we're removing the top two lines
# then remove the two now blank lines
spawn bash
send {sed -e s/"#TYPE Selected.Microsoft.Management.Infrastructure.CimInstance"//g -i dhcpleases.csv}
send "\r"
send {sed -e s/"[\"]Hostname[\"],[\"]ClientId[\"],[\"]IPAddress[\"],[\"]LeaseExpiryTime[\"]"//g -i dhcpleases.csv}
send "\r"
send {sed '1,2d' -i dhcpleases.csv}
send "\r"
expect eof
