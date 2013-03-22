#!/bin/bash

# Configuration, change if needed, defaults are quite fine

_rpmforge_rpm_url="http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"
_rpmforge_rpm_file="rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"""

# Private stuff, change at your own risk

_to='f' #test only
_command=''

echo """Basic CentOS 6.x x64 post install script
Please do update OS before you continue.

WARINING - Attempting to run this script on operating system that isn't CentOS 6.x might reslut in permanent damage to your system.

"""

if [ ! -f "functions.sh" ]; then
  echo "Missing functions file, aborting!"
  exit 0
fi

source functions.sh

read -p """Press [enter] to continue, or ^C to abort.
"""

if [ "$(uname)" != "Linux" ]; then 
  echo """
WARNING!
Not running a Linux system!
Script will continue, but it will not execute any commands.
"""

  _to='t'
fi

if [ "$USER" != "root" ]; then
  echo """

You must be 'root' to run this script

"""
  if [ "$_to" = 'f' ]; then
    exit 0
  else
    echo """Just testing, will continue.
"""
  fi  
fi
# TODO implement CentOS version checking here - check next line
# cat /etc/*elease | uniq | grep -o "CentOS"

# Note, minimal CentOS install is missing wget, us curl to install RPMForge

_command='curl -s -L '$_rpmforge_rpm_url' > '$_rpmforge_rpm_file
printExecuteCommand "$_to" "$_command"
checkLastReturn """
Failed to download RPMForge .rpm file."""

_command="rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt"
printExecuteCommand "$_to" "$_command"
checkLastReturn """
Failed to import RPMForge key."""

_command='rpm -K rpmforge-release-0.5.2-2.el6.rf.*.rpm'
printExecuteCommand "$_to" "$_command"
checkLastReturn """
Failed to verify downloaded file."""

_command='rpm -i rpmforge-release-0.5.2-2.el6.rf.*.rpm'
printExecuteCommand "$_to" "$_command"
checkLastReturn """
Failed to instal .rpm file."""

if [ ! -f "basic-packages.conf" ]; then
  echo """
Failed to find packages configuration."""
  exit 0
fi

_packages=''
while read _line
do
  if [[ "$_line" =~ "^#.*" ]]; then
    continue
  fi
    
  _line=${_line//  / }
  _line=${_line%%#*}

  if [ -z "$_line" ]; then
    continue
  fi

  _packages=$_packages" "$_line
done < "basic-packages.conf"

_command='yum -y install '$_packages
printExecuteCommand "$_to" "$_command"
checkLastReturn """
Failed to install packages"""

