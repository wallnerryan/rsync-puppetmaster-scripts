#!/bin/sh

# Simple rsync "driver" script. Modified for Puppet
# This script will sync both modules and manifests from
# every NON-CA puppetmaster the the designated collector Puppetmaster.
# (Uses SSH as the transport layer.)
# http://www.scrounge.org/linux/rsync.html


# Destination host machine name
# This is the "collector"
DEST="puppetca"

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

#rsync modules and manifests to the collective master
# Only run rsync if $DEST responds.
VAR=`ping -s 1 -c 1 $DEST > /dev/null; echo $?`
if [ $VAR -eq 0 ]; then
    rsync $OPTS $MODULES $USER@$DEST:$MODULESDEST
    rsync $OPTS $MINIFESTS $USER@$DEST:$MANIFESTSDEST
else
    echo "Cannot connect to $DEST."
fi