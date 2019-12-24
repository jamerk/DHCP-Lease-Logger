#!/bin/bash

# Be sure to set your database login information on lines 84,87,90,91

# Time Keeper Start
datestart=$(date +%S)

# Make a call to the Glass API, set the IP here
data=$(curl -s http://IP_OF_YOUR_GLASS_DHCP_SERVER:3000/api/get_active_leases)

# Seperate each device entry with a +
plusdata=$(sed -r 's/},"1/+1/g' <<<"$data")

arraysp=$(sed -r 's/ /_/g' <<<"$plusdata")

# Split each device entry into their own array position
IFS='+' read -ra array <<< "$arraysp"


## FILTERING BELOW ##

# Find and get each MAC address
mcount=0
for eachmac in "${array[@]}"
do
  mac_array[mcount]=$(grep -oP '[0-9a-f]{1,2}([\.:-])(?:[0-9a-f]{1,2}\1){4}[0-9a-f]{1,2}' <<< $eachmac)
  mcount=$((mcount+1))
done

# Find and get each hostname
hcount=0
for eachhost in "${array[@]}"
do
  host_array[hcount]=$(grep -oP '(?<="host":")(.*)(?=")' <<< $eachhost)
  hcount=$((hcount + 1))
done

# Find and get each MAC Vendor
vcount=0
for eachvendor in "${array[@]}"
do
  vendor_array[vcount]=$(grep -oP '(?<="mac_oui_vendor":")(.*?)(?=")' <<< "$eachvendor")
  vcount=$((vcount+1))
done

# Find and get each lease start time
tcount=0
for eachtime in "${array[@]}"
do
  time_array[tcount]=$(grep -oP '(?<="start":)\d{10}' <<< $eachtime)
  tcount=$((tcount+1))
done
# Convert the above epoch values into time stamps
tvcount=0
for eachepoch in "${time_array[@]}"
do
  truetime[tvcount]=$(date -d @"$eachepoch")
  tvcount=$((tvcount+1))
done


# Find and get each IP
ipcount=0
for eachip in "${array[@]}"
do
  ip_array[ipcount]=$(grep -oP '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' <<< $eachip)
  ipcount=$((ipcount+1))
done

## END FILTERING ##

# Echo total DHCP leases currently active
echo $tvcount;

# Combine each value of the above arrays into one array
finalcount=0
for eachresult in "${mac_array[@]}"
do
  finalarray[finalcount]=$(echo '"'$eachresult'"'',' '"'${truetime[finalcount]}'"'',' '"'${host_array[finalcount]}'"'',' '"'${vendor_array[finalcount]}'"'',' '"'${ip_array[finalcount]}'"')
  finalcount=$((finalcount+1))
done

# Insert each row of values from the above array into the table of devices
for i in "${finalarray[@]}"; do echo "INSERT INTO devices (mac, datetime, hostname, manufacturer, ip) values ($i);" | mysql -u YOUR_DB_USER -pYOUR_DB_USER_PASSWORD devicedb; done

# Re-count the ID column
echo "SET @count = 0; UPDATE devices SET devices.id = @count:= @count + 1; ALTER TABLE devices AUTO_INCREMENT = 1;" | mysql -u YOUR_DB_USER -pYOUR_DB_USER_PASSWORD devicedb;

# Replace NULL values in hostname and manufacturer with UNKNOWN
echo "UPDATE devices SET hostname='UNKNOWN' WHERE hostname='';" | mysql -u YOUR_DB_USER -pYOUR_DB_USER_PASSWORD devicedb;
echo "UPDATE devices SET manufacturer='NoneFound' WHERE manufacturer='';" | mysql -u YOUR_DB_USER -pYOUR_DB_USER_PASSWORD devicedb;


# Time Keeper End
dateend=$(date +%S)

# Time Keeper MATH to show the run time of the script
echo "This script took" "$(($dateend-$datestart))" "Seconds to run."
