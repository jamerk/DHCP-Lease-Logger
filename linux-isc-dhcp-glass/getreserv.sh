#!/usr/bin/expect -f

# Fill in these variables for your DHCP server
set username USER
set password PASSWORD
set server DHCP_SERVER_IP

# Spawn a new bash session to copy the dhcp config file
spawn bash
expect "*#" {send "scp $username@$server:/etc/dhcp/dhcpd.conf /root/Device_Logger/\r"}
expect "*password:" {send "$password\r"}
expect "*#" {send "exit\r"}
expect eof
