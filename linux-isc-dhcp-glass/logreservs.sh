#!/bin/bash

# Time Keeper Start
datestart=$(date +%S)

# Run an expect script to download the dhcp config file from the dhcp server
./getreserv.sh

# Log all of the output of this script
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>>/var/log/logleasesdb.log 2>&1
exec 1>>/var/log/reslogleasesdb.log 2> /dev/null

# Uncomment the line above with 2>&1 on the end and comment the line
# with /dev/null on the end to get a tiny bit more verbosity

## Get the MAC, Hostname, and IP of each DHCP reservation
resmacs=($(grep -oP '(?<=hardware ethernet )(.*)(?=;)' < dhcpd.conf))
reshosts=($(grep -oP '(?<=host )(.*)(?= {)' < dhcpd.conf))
resips=($(grep -oP '(?<=fixed-address )(.*)(?=;)' < dhcpd.conf))


# Combine each value of the above arrays into one array
rescount=0
for resresult in "${resmacs[@]}"
do
  resarray[rescount]=$(echo '"'$resresult'"'',' '"'RESERVATION'"'',' '"'${reshosts[rescount]}'"'',' '"'${resips[rescount]}'"')
  rescount=$((rescount+1))
done

# Insert each row of values from the above array into the table of devices
for one in "${resarray[@]}"; do echo "INSERT INTO devices (mac, datetime, hostname, ip) values ($one);" | mysql -u YOUR-SQL-USER -pYOUR-SQL-USER-PASSWORD devicedb; done

# Re-count the ID column
echo "SET @count = 0; UPDATE devices SET devices.id = @count:= @count + 1; ALTER TABLE devices AUTO_INCREMENT = 1;" | mysql -u YOUR-SQL-USER -pYOUR-SQL-USER-PASSWORD devicedb;

# Count leases
counter=${#resmacs[@]}

# Time Keeper End
dateend=$(date +%S)

# Set time for the log
logtime=$(date)

# Time Keeper MATH to show the run time of the script
# Also showing the total leases found
echo $logtime" This script took" "$(($dateend-$datestart))" "Seconds to run and found" $counter "total leases."
