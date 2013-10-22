#!/bin/sh

# Simple rsync "driver" script. Modified for Puppet
# This script will sync the "collectors" manifests and modules
# to evert puppet master defined in the "PUPMASTERS" array/
# THIS SCRIPT SHOULD RUN DIRECTLY AFTER THE NON-CA RSYNC SCRIPT
# (Uses SSH as the transport layer.)
# http://www.scrounge.org/linux/rsync.html

# This script will update every puppetmaster with updated minifests
# and modules, this script should ONLY run after non CA Puppet-servers
# have updated the Master Collection

#DNS or IP Addresses of masters to be updated
PUPMASTERS =("master01","master02","master03","192.168.192.20")

# User that rsync will connect as
# Are you sure that you want to run as root, though?
USER="root"

# Directories to copy from on the source machine.
MODULES="/var/lib/puppet/modules/"
MANIFESTS="/etc/puppet/manifests/"

# Directory to copy to on the destination machine.
MODULESDEST="/var/lib/puppet/modules/"
MANIFESTSDEST="/etc/puppet/manifests/"

# excludes file - Contains wildcard patterns of files to exclude.
# i.e., *~, *.bak, etc.  One "pattern" per line.
# You must create this file.
# EXCLUDES=/root/bin/excludes

# Options.
# -n Don't do any copying, but display what rsync *would* copy. For testing.
# -a Archive. Mainly propogate file permissions, ownership, timestamp, etc.
# -u Update. Don't copy file if file on destination is newer.
# -v Verbose -vv More verbose. -vvv Even more verbose.
# See man rsync for other options.

# For testing.  Only displays what rsync *would* do and does no actual copying.
OPTS="-n -vv -u -a --rsh=ssh --exclude-from=$EXCLUDES --stats --progress"
# Does copy, but still gives a verbose display of what it is doing
#OPTS="-v -u -a --rsh=ssh --exclude-from=$EXCLUDES --stats"
# Copies and does no display at all.
#OPTS="--archive --update --rsh=ssh --exclude-from=$EXCLUDES --quiet"

# May be needed if run by cron?
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin

#Start the rsync for each puppet-server, linearly
i=0
len=${#PUPMASTERS[*]}
while [ $i -lt $len]; do
    DEST=${PUPMASTERS[$i]}
    #rsync modules and manifests to the collective master
    # Only run rsync if $DEST responds.
    VAR=`ping -s 1 -c 1 $DEST > /dev/null; echo $?`
    if [ $VAR -eq 0 ]; then
        rsync $OPTS $MODULES $USER@$DEST:$MODULESDEST
        rsync $OPTS $MINIFESTS $USER@$DEST:$MANIFESTSDEST
    else
        echo "Cannot connect to $DEST."
    fi
    
    let i++
done