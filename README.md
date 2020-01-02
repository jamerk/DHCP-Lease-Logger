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
