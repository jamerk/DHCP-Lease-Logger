# DHCP Lease Logger
A set of scripts for logging MAC, hostname, IP, and MAC Vendor from various DHCP Servers to a MySQL DB
<br><br>
Current DHCP Servers Supported:<br>
Windows DHCP Server (Via Bash/PowerShell over SSH)<br>
Linux ISC DHCP Server via Glass API (https://github.com/Akkadius/glass-isc-dhcp)<br>
<br><br>
## General Setup<br>
If you are using the Windows piece please also see the ReadMe in the Windows DHCP Server folder.<br><br>
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
I would recommend running these scripts from the same server the database lives on (Otherwise you'll need to make some changes in the scripts) and creating a folder for these scripts to live in on that server, especially for the windows dhcp server scripts.<br><br>
To have your database of client devices populated regularly you should have the script(s) run as cron jobs, I store mine in a file at /etc/cron.d/dhcplogger. Here is an example of running the Linux DHCP logging script every hour and then running an export of the SQL database every day at 11:10 PM so my Borg backup job can pick it up at 12 AM, I am running the script as root but you do not have to and am storing the script in a folder in the root home folder):
```
0 * * * * root bash /root/Device_Logger/logleases.sh
10 23 * * * root mysqldump -u YOUR-SQL-USER -pYOUR-SQL-USER-PASSWORD devicedb > /root/Device_Logger/DB-BACKUPS/devicedb.sql
```
And here are the two scripts you need for Windows DHCP servers, getting the DHCP leases CSV every 20 minutes into the hour and adding to the database every 35 minutes into the hour, I am running them as root but you do not have to and am storing the scripts in a folder in the root home folder):
```
20 * * * * root bash /root/Device_Logger/getwinleases.sh
35 * * * * root bash /root/Device_Logger/winlogleases.sh
```

## Credits<br>
https://stackoverflow.com/questions/27004013/grep-through-array-in-bash<br>
https://stackoverflow.com/questions/2576622/bash-assign-grep-regex-results-to-array<br>
https://stackoverflow.com/questions/29228769/mac-address-regex-for-javascript<br>
https://unix.stackexchange.com/questions/499027/sum-and-count-in-for-loop<br>
https://stackoverflow.com/questions/6109882/regex-match-all-characters-between-two-strings<br>
https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash<br>
https://stackoverflow.com/questions/36439056/how-to-add-elements-to-an-array-in-bash-on-each-iteration-of-a-loop<br>
https://stackoverflow.com/questions/16311688/bash-convert-epoch-to-date-showing-wrong-time<br>
http://lubos.rendek.org/insert-data-to-mysql-table-using-bash-command-line/<br>
https://gist.github.com/carloscarcamo/28441ee9b3a9c7807ce4<br>
https://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-a-text-file<br>
https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions<br>
https://stackoverflow.com/questions/8206280/delete-all-lines-beginning-with-a-from-a-file<br>
