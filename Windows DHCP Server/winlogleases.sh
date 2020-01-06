#!/bin/bash

# Path to where this script is located
path=/root/Device_Logger/

# Time Keeper Start
datestart=$(date +%S)

# Log all of the output of this script
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>>/var/log/logleasesdb.log 2>&1
exec 1>>/var/log/winlogleasesdb.log 2> /dev/null

# Uncomment the line above with 2>&1 on the end and comment the line
# with /dev/null on the end to get a tiny bit more verbosity


# Remove quotes in file
sed -e 's/"//g' /root/Device_Logger/dhcpleases.csv > /root/Device_Logger/dhcpleasesuno.csv

# Remove domain name from hostnames
sed -e 's/.infineonrw.internal//g' /root/Device_Logger/dhcpleasesuno.csv > /root/Device_Logger/dhcpleasesdo.csv
sed -e 's/.domain//g' /root/Device_Logger/dhcpleasesdo.csv > /root/Device_Logger/dhcpleasesmod.csv

# Get each MAC address from column in the CSV
dwinmacs=( $(cut -d ',' -f2 /root/Device_Logger/dhcpleasesmod.csv ) )

# Replace the dashes in the MAC addresses with colons
macount=0
for macco in "${dwinmacs[@]}"
do
  winmacs[macount]=$(sed -r 's/-/:/g' <<< $macco)
  macount=$((macount + 1))
done

# Get each Hostname from column in the CSV
# Cut wasn't working here for some reason
winhcount=0
while IFS="" read -r winhost || [ -n "$winhost" ]
do
  winhosts[winhcount]=$(grep -oP '.*(?=,[0-9a-f]{1,2}([\.:-])(?:[0-9a-f]{1,2}\1){4}[0-9a-f]{1,2})' <<< $winhost)
  winhcount=$((winhcount + 1))
done < /root/Device_Logger/dhcpleasesmod.csv

# Get each IP address from column in the CSV
winips=( $(cut -d ',' -f3 /root/Device_Logger/dhcpleasesmod.csv ) )

# Had to add underscores to lease expiration date or regex will split date/time
sed -e 's/\s\+/_/g' /root/Device_Logger/dhcpleasesmod.csv > /root/Device_Logger/dhcpleasesfinal.csv

# Get each lease expiration date from column in CSV
# Cut also was not working here
winetcount=0
while IFS="" read -r winexp || [ -n "$winexp" ]
do
  winexps[winetcount]=$(grep -oP '(\d{2}\/\d{2}\/\d{4}_)(\d{1,2}:\d{2}:\d{2}_)(AM|PM)' <<< $winexp)
  winetcount=$((winetcount + 1))
done < /root/Device_Logger/dhcpleasesfinal.csv


# Loop through each array and create a new array with part of our SQL query
wincount=0
for eachresult in "${winmacs[@]}"
do
  winfinal[wincount]=$(echo '"'$eachresult'"'',' '"'${winexps[wincount]}'"'',' '"'${winhosts[wincount]}'"'',' '"'${winips[wincount]}'"')
  wincount=$((wincount+1))
done

# Insert each row of values from the above array into the table of devices
for i in "${winfinal[@]}"; do echo "INSERT INTO devices (mac, datetime, hostname, ip) values ($i);" | mysql -u deb_sql -pd4nk0v1510n45 devicedb; done

# Re-count the ID column
echo "SET @count = 0; UPDATE devices SET devices.id = @count:= @count + 1; ALTER TABLE devices AUTO_INCREMENT = 1;" | mysql -u deb_sql -pd4nk0v1510n45 devicedb;

# Mark empty datetime values as Reservations
echo "UPDATE devices SET datetime='Reservation' WHERE datetime='';" | mysql -u deb_sql -pd4nk0v1510n45 devicedb;

# Set time for the log
logtime=$(date)

# Time Keeper End
dateend=$(date +%S)

# Time Keeper MATH to show the run time of the script
# Also showing the total leases found
echo $logtime" This script took" "$(($dateend-$datestart))" "Seconds to run and found" $wincount "total leases on your Windows DHCP Server."
echo "Including Reservations!"

# Clean up the mess I made
rm /root/Device_Logger/dhcpleasesuno.csv
rm /root/Device_Logger/dhcpleasesdo.csv
rm /root/Device_Logger/dhcpleasesmod.csv
rm /root/Device_Logger/dhcpleasesfinal.csv
