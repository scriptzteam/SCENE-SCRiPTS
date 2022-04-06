
This README explains how you can set up source-routing, or multi-routing, which enables you to use more than 
one connection to the internet simultaneously.  A default installation uses the first gateway in the kernel 
routing table, and any additional gateways are left unused.  This is obviously not the desired behavior, so 
we must make some changes to the routing table and the glftpd configuration file.  The following instructions 
and scripts were constructed to help you accomplish this task.

Original concept by Bloody_A
Re-written/enhanced by t0xic

=====================================================================

1. First, you need to configure your kernel to support some advanced IP Routing features:

   CONFIG_IP_ADVANCED_ROUTER (IP: advanced router under menuconfig)
   CONFIG_IP_MULTIPLE_TABLES (IP: policy routing under menuconfig)

   Compile both of these options into your kernel, if they are not already, and then continue to the next step.
   Instructions on compiling/installing a kernel is beyond the scope of this README.  Check these URLs for more
   information:  

   http://www.linux.org/docs/ldp/howto/Kernel-HOWTO.html
   http://www.linux.org/docs/ldp/howto/mini/LILO.html

2. Second, you need to download the iproute2 package.  This enables the use of the advanced routing features
   that we added to the kernel in the first step.  You can get it here:

   ftp://ftp.inr.ac.ru/ip-routing/ 
   
   Download, compile, and install this package.  All of the instructions for getting it running are included.

3. Now we need to put it all together by building some alternate kernel routing rules.  There are step-by-step
   instructions below for those people with static addresses.  There is also a script at the bottom that was 
   written to do everything from start to finish for DHCP users.

   REMEMBER:  The solution to multi-link is two-fold.  First, the kernel routing tables must forward the traffic
   to/from glftpd properly.  Once this is done, glftpd must be configured to use multiple devices.  Only when
   both conditions are met will multi-link work properly.

4. (LINUX/OPTIONAL) If you have all NIC's on the same subnet/network it might be needed to enable the arp filter 
   to prevent the server from replying with the same arp response for all ip's. This can be done by setting 
   /proc/sys/net/ipv4/conf/DEV/arp_filter to 1 (replacing DEV with the right interface) for all interfaces
   connected to the same subnet/network.

### >> STATIC IP NETWORK CONFIGURATION:

# STEP 1:
#
# iproute2 creates a file called /etc/iproute2/rt_tables (by default) -- you will need to add new routing rules 
# for each device that you want to use.  for the rest of this document, we will assume there are 2 devices 
# (eth0, eth1):
                
# --------------------------------------- begin /etc/iproute2/rt_tables --------------------------------------- #
                
255     local
254     main                    
253     default
0       unspec
        
1       Nic1
2       Nic2    

# ---------------------------------------- end /etc/iproute2/rt_tables ---------------------------------------- #

# STEP 2:       
# 
# next you will need to convert the NETMASK (e.g. 255.255.128.0) to binary (17) -- if you already know what this 
# number is for each of your devices, continue to the next step, otherwise keep reading.
#
# every IP address is a set of 4 numbers separated by periods -- each having a maximum value of 255.  The table 
# below shows a decimal value, and its binary equivalent:
# 
# 255 = 8       
# 254 = 7
# 252 = 6       
# 248 = 5
# 240 = 4                       
# 224 = 3
# 192 = 2
# 128 = 1
# 0 = 0
# 
# to arrive at the binary value of a NETMASK, simply add the binary values of the 4 octets together.  you will 
# need this number for every device that you plan to use.  for example:
# 
# 255.255.128.0 =
#  8 + 8 + 1 + 0 = 17

# STEP 3:  
# 
# once the rules are defined in /etc/iproute2/rt_tables, we can tell iproute2 what each rule should do.  assume 
# the following:
#
# IP1=64.233.208.150
# IP2=64.233.209.151  
#
# NETWORK1=64.233.208.0
# NETWORK2=64.233.209.0
# 
# NETMASK1=255.255.254.0 (23)
# NETMASK2=255.255.192.0 (18)
#
# GATEWAY1=64.233.208.1
# GATEWAY2=64.233.209.1
# 
# substitute the information below with yours:
#

# ---------------------------------------- begin rc.multilink (STATIC) ---------------------------------------- #
                
#!/bin/bash
                                
# create rule for eth0
/usr/local/bin/ip rule add from 64.233.208.150 lookup Nic1
/usr/local/bin/ip rule add to 64.233.208.150 lookup Nic1

# create rule for eth1
/usr/local/bin/ip rule add from 64.233.209.151 lookup Nic2
/usr/local/bin/ip rule add to 64.233.209.151 lookup Nic2

# add instructions for eth0
/usr/local/bin/ip route flush table Nic1
/usr/local/bin/ip route add 64.233.208.150 dev eth0 scope link table Nic1
/usr/local/bin/ip route add 64.233.208.0/23 dev eth0 proto kernel scope link src 64.233.208.150 table Nic1
/usr/local/bin/ip route add default via 64.233.208.1 dev eth0 table Nic1
                
# add instructions for eth1     
/usr/local/bin/ip route flush table Nic2
/usr/local/bin/ip route add 64.233.209.151 dev eth1 scope link table Nic2
/usr/local/bin/ip route add 64.233.209.0/18 dev eth1 proto kernel scope link src 64.233.209.151 table Nic2
/usr/local/bin/ip route add default via 64.233.209.1 dev eth1 table Nic2
        
# ----------------------------------------- end rc.multilink (STATIC) ----------------------------------------- #
        
# STEP 4:       
#               
# now that the kernel routing rules are done, and the tables have been updated, it's time to tell glftpd what 
# we've done.  create a file similiar to the following (substituting your own active/pasv addresses):
                
# ----------------------------------------- begin /etc/multilink.conf ----------------------------------------- #  
                
ifip 10.* 192.168.*
elseip

active_addr 64.233.208.150
pasv_addr 64.233.208.150

active_addr 64.233.209.151
pasv_addr 64.233.209.151
                
endifip
                
# ------------------------------------------ end /etc/multilink.conf ------------------------------------------ #
                
# STEP 5:   
#                               
# add a line to your glftpd.conf like this:
        
include /etc/multilink.conf
        
# this will tell glftpd to use all of your devices

# STEP 6:       
#
# call rc.multilink from one of your startup scripts (/etc/rc.d/rc.local for example) and you are DONE!

### >> DHCP IP NETWORK CONFIGURATION:

# ----------------------------------------- begin rc.multilink (DHCP) ----------------------------------------- #

# rc.multilink - execute this on startup (from /etc/rc.d/rc.local for example)
#
# original concept by bloody_a
# re-written/enhanced by t0xic
#
# description: 
#
# defines routing rules in iproute2 which will allow one device to receive all incoming traffic and then 
# distribute the load to several other devices in a round-robin fashion (this is NOT bandwidth aggregation) -- 
# also configures glftpd to use multiple active/pasv addresses

#!/bin/bash

external_devices=4
device_names="eth0 eth1 eth2 eth3"

ml_conf="/etc/multilink.conf"
gl_conf="/etc/glftpd.conf"
gl_temp="/etc/glftpd.temp"

# --- do not edit below this point --- #

echo "255     local"    > /etc/iproute2/rt_tables
echo "254     main"     >> /etc/iproute2/rt_tables
echo "253     default"  >> /etc/iproute2/rt_tables
echo "0       unspec"   >> /etc/iproute2/rt_tables
echo "#"                >> /etc/iproute2/rt_tables

echo > $ml_conf
echo "ifip 10.* 192.168.*" >> $ml_conf
echo "elseip" >> $ml_conf
echo >> $ml_conf

iproute2=`which ip`

inc=1
while [ $inc -le $external_devices ]; do
        for device in $device_names; do

                octet=1
                counter=0
                metric=0

                netmask=`grep NETMASK /etc/dhcpc/dhcpcd-$device.info | awk -F = '{print $NF}'`
                gateway=`grep GATEWAY /etc/dhcpc/dhcpcd-$device.info | awk -F = '{print $NF}'`
                network=`grep NETWORK /etc/dhcpc/dhcpcd-$device.info | awk -F = '{print $NF}'`
                ip=`grep IPADDR /etc/dhcpc/dhcpcd-$device.info | awk -F = '{print $NF}'`
                quad1=`echo $netmask | cut -d. -f1`
                quad2=`echo $netmask | cut -d. -f2`
                quad3=`echo $netmask | cut -d. -f3`
                quad4=`echo $netmask | cut -d. -f4`

                while [ $octet -le 4 ]; do
                        case $[quad$[octet]] in
                                255) counter="8" ;;
                                254) counter="7" ;;
                                252) counter="6" ;;
                                248) counter="5" ;;
                                240) counter="4" ;;  
                                224) counter="3" ;;
                                192) counter="2" ;;
                                128) counter="1" ;;
                                0)   counter="0" ;;
                        esac
        
                        let metric=$[metric+counter]
                        let octet=octet+1
                done
                
                echo "$inc       Nic$inc"        >> /etc/iproute2/rt_tables

                echo "active_addr $ip" >> $ml_conf
                echo "pasv_addr $ip" >> $ml_conf
		echo >> $ml_conf                

                $iproute2 rule add from $ip lookup Nic$inc
                $iproute2 rule add to $ip lookup Nic$inc
                $iproute2 route flush table Nic$inc
                $iproute2 route add $ip dev $device scope link table Nic$inc
                $iproute2 route add $network/$metric dev $device proto kernel scope link src $ip table Nic$inc
                $iproute2 route add default via $gateway dev $device table Nic$inc
                
                let inc=inc+1
        done
	
	echo "include $ml_conf" > $gl_temp
        cat $gl_conf | grep -v $ml_conf >> $gl_temp
        cp $gl_conf $gl_conf.backup
        mv $gl_temp $gl_conf
	
done

echo "endifip" >> $ml_conf

# ------------------------------------------ end rc.multilink (DHCP) ------------------------------------------ #
