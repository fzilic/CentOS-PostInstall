#!/bin/bash

# Install using since basic CentOS might not have wget
#
# curl -s -L https://raw.github.com/fzilic/CentOS-PostInstall/master/CentOS-PostInstall-01.sh > CentOS-PostInstall-01.sh && curl -s -L https://raw.github.com/fzilic/CentOS-PostInstall/master/basic-packages.conf > basic-packages.conf && chmod +x CentOS-PostInstall-01.sh && ./CentOS-PostInstall-01.sh

# Configuration, change if needed, defaults are quite fine

# rpmforge setup configuration
# _arch_ will be replaced as needed
_rpmforge_rpm_url="http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf._arch_.rpm"
_rpmforge_rpm_file="rpmforge-release-0.5.2-2.el6.rf._arch_.rpm"""

# which architecture are we running on 
# Allowed values are "x86_64" or "i686"
_arch="x86_64"

# used for local VMs only - be careful for public stuff :D
_disable_pointelss_security="t"

# edit sudoers to allow sudo for wheel group without a password
_sudoers="t"

# update locatedb
_locate_upd="t"

# !!!!! Private stuff, change at your own risk !!!!! #

checkLastReturn() {
  if [[ "$?" != "0" ]]; then 
    echo $?
    echo $1
    exit 0
  fi
}

printExecuteCommand() {
  if [ "$#" -ne "2" ]; then
    echo "Wrong function call."
    exit 0
  fi
  
  echo $2
  if [ "$1" = 'f' ]; then
    echo $2 | /bin/bash
  fi
}

if [ "$_arch" != "x86_64" -a "$_arch" != "i686" ]; then
  echo "Unknown architecture configured, aborting"
  exit 0
fi

# test only
_to='f' 
_command=''

clear 

echo """
Basic CentOS 6.x $_arch post install script
Please do update OS before you continue.

WARINING - Attempting to run this script on operating system that isn't CentOS 6.x might reslut in permanent damage to your system.

"""

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

if [ "$(uname -m)" != "$_arch" -a "$_to" = "f" ]; then
  echo "You are not running configured architecture"
  exit 0
fi

if [ "$_arch" = "x86_64" ]; then
  _rpmforge_rpm_url=${_rpmforge_rpm_url//_arch_/x86_64}
  _rpmforge_rpm_file=${_rpmforge_rpm_file//_arch/x86_64}
else
  _rpmforge_rpm_url=${_rpmforge_rpm_url//_arch_/i686}
  _rpmforge_rpm_file=${_rpmforge_rpm_file//_arch/i686}
fi

if [ "$(cat /etc/*elease 2>/dev/null | uniq | grep -o 'CentOS')" != "CentOS" ]; then
  echo "You don't apear to run CentOS"
  
  if [ "$_to" = "f" ]; then
    exit 0
  else
    echo """Just testing, will continue.
"""
  fi 
fi

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

_command='rm -f rpmforge-release-0.5.2-2.el6.rf.*.rpm'
printExecuteCommand "$_to" "$_command"

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

if [ "$_disable_pointelss_security" = "t" ]; then
  _command='chkconfig | grep -q "iptables"'
  printExecuteCommand "$_to" "$_command"

  _command='chkconfig --del iptables'
  printExecuteCommand "$_to" "$_command"

  _command='chkconfig | grep -q "ip6tables"'
  printExecuteCommand "$_to" "$_command"

  _command='chkconfig --del ip6tables'
  printExecuteCommand "$_to" "$_command"

  _command='chkconfig | grep -q "iptables"'
  printExecuteCommand "$_to" "$_command"

  _command='setenforce 0'
  printExecuteCommand "$_to" "$_command"

  _command='sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config'
  printExecuteCommand "$_to" "$_command"
fi

if [ "$_sudoers" = "t" ]; then
  _command="sed -i 's/^# \(.wheel.*NOPASSWD.*\)/\1/' /etc/sudoers"
  printExecuteCommand "$_to" "$_command"
fi

if [ "$_locate_upd" = "t" ]; then
  _command="updatedb"
  printExecuteCommand "$_to" "$_command"
fi

