#!/bin/bash
#------------------------------------------------------------------------------
# 
# Basic diagnostic script
# 
# Compiler: Nate Mitchell <nahtanjamesmitchell@gmail.com>
#
# License ISC License
# 
# Copyright (c) 2013, Nate Mitchell <nathanjamesmitchell@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
#------------------------------------------------------------------------------

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset

# Check if server has VPNs installed
vpnYES=$(ifconfig | grep tun | wc -l)
# Check for dropped packets on all interfaces (Treat as Boolean 0 / 1+)
packetDROP=$(ifconfig | grep packets | awk '{print $4}' | grep "[1-9]" | wc -l)

# Get RAID status in output format "[UU]"
statusRaid=$(cat /proc/mdstat | grep blocks | awk '{print $4}')
# Get local IP address
localIP=$(ifconfig eth0 | grep "inet addr" | cut -d: -f2 | awk '{print $1}')
# Get external IP address
externalIP=$(curl -s http://ifconfig.me)
# Get RAID size
sizeHDD=$(df -h | grep md | awk '{print $2}')
# Get RAID usage
usedHDD=$(df -h | grep md | awk '{print $3}')
# Get RAID space available
availHDD=$(df -h | grep md | awk '{print $4}')
# Get RAID usage percentage
percentHDD=$(df -h | grep md | awk '{print $5}')
# Get system load average
loadAverage=$(w | grep "lad av" | awk -F":" '{print $5}')
# Get RAM total
totalRAM=$(cat /proc/meminfo | grep -i memtotal | awk '{print $2}')


echo -e "$txtbld Diagnostic Script" $txtrst
echo -e "----------------------------------------------------------------------"
echo ""
echo -e "$txtbld Network Information:" $txtrst
echo -e "----------------------------------------------------------------------"
if [ $packetDROP -eq 1 ]
  then
	echo -e "$txtred ERROR: Dropped packets on a network interface!"
	echo -e " Recommend checking 'ifconfig' output" $txtrst
fi
echo -e "$txtbld IP Addresses" $txtrst
echo -e " Local IP: $localIP"
echo -e " External IP: $externalIP"
echo ""
echo -e "$txtbld VPN Addresses" $txtrst
if [ $vpnYES -gt 0 ]
  then
	for i in $(ifconfig | grep tun |awk '{print $1}'); do echo $i $(ifconfig $i | grep -A2 $i | grep "inet addr" | cut -d: -f2 | awk '{print $1}') $(ifconfig $i | grep -A2 $i | grep "inet addr" | cut -d: -f3 | awk '{print $1}'); done 
  else
	echo -e "$txtbld There are no VPNs currently running on this server" $txtrst
fi
echo ""
echo "$txtbld System Information" $txtrst
echo -e "----------------------------------------------------------------------"
echo -e " RAID Status: $statusRaid"
if [ $statusRaid -eq '[UU]']
  then
	echo -e " RAID Status OKAY"
  else
	echo -e "$txtred RAID Status FAILED"
	echo -e " Recommend checking output of 'cat /proc/mdstat'" $txtrst
fi
echo -e " RAID Size: $sizeHDD"
echo -e " RAID Space Available: $availHDD"
echo -e " RAID Usage Percentage: $percentHDD"

