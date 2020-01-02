# DHCP Lease Logger
A set of scripts for logging MAC, hostname, IP, and MAC Vendor from various DHCP Servers to a MySQL DB
<br><br>
Current DHCP Servers Supported:<br>
Windows DHCP Server (Via PowerShell over SSH) [Almost Ready!]<br>
Linux ISC DHCP Server via Glass API (https://github.com/Akkadius/glass-isc-dhcp)<br>
<br><br>
## General Setup<br>
Setup a MySQL/MariaDB Database called devicedb with a table called devices that looks like this:<br>
```
+--------------+-------------+------+-----+---------+----------------+
| Field        | Type        | Null | Key | Default | Extra          |
+--------------+-------------+------+-----+---------+----------------+
| id           | int(11)     | NO   | PRI | NULL    | auto_increment |
| mac          | varchar(17) | NO   | UNI | NULL    |                |
| hostname     | varchar(45) | YES  |     | NULL    |                |
| ip           | varchar(15) | YES  |     | NULL    |                |
| manufacturer | varchar(45) | YES  |     | NULL    |                |
| datetime     | varchar(30) | NO   |     | NULL    |                |
+--------------+-------------+------+-----+---------+----------------+
```
Both hostname and manufacturer varchar limits can be adjusted, I have them large so nearly any length can be accepted. The most important thing is to set the mac column as unique so no duplicates will be inserted.<br><br>
I would recommend running these scripts from the same server the database lives on and creating a folder for these scripts to live in on that server, especially for the windows dhcp server scripts.<br><br>
To have your database of client devices populated regularly you should have the script(s) run as cron jobs, I store mine in a file at /etc/cron.d/dhcplogger. Here is an example of running the Linux DHCP logging script every hour and then running an export of the SQL database every day at 11:10 PM so my Borg backup job can pick it up at 12 AM:
```
0 * * * * root bash /root/Device_Logger/logleases.sh
10 23 * * * root mysqldump -u deb_sql -pd4nk0v1510n45 devicedb > /root/Device_Logger/DB-BACKUPS/devicedb.sql
```
And here are the two scripts you need for Windows DHCP servers, getting the DHCP leases CSV every 20 minutes into the hour and adding to the database every 35 minutes into the hour:
```
20 * * * * root bash /root/Device_Logger/getwinleases.sh
35 * * * * root bash /root/Device_Logger/winlogleases.sh
```
