#!/bin/bash

#  Copyright (c) 2014, Franjo Žilić
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  The views and conclusions contained in the software and documentation are those
#  of the authors and should not be interpreted as representing official policies,
#  either expressed or implied, of the FreeBSD Project.


#http://dl.atrpms.net/all/atrpms-repo-6-7.el6.x86_64.rpm
#http://dl.atrpms.net/all/atrpms-repo-6-7.el6.i686.rpm

#http://dl.atrpms.net/all/atrpms-repo-5-7.el5.x86_64.rpm
#http://dl.atrpms.net/all/atrpms-repo-5-7.el5.i386.rpm

_atrpms_rpm_url="http://dl.atrpms.net/all/atrpms-repo-_version_-7.el6._arch_.rpm"

#atrpms-repo-6-7.el6.x86_64.rpm
#atrpms-repo-6-7.el6.i686.rpm

#atrpms-repo-5-7.el5.x86_64.rpm
#atrpms-repo-5-7.el5.i386.rpm
_atrpms_rpm_file="atrpms-repo-6-7.el_version_._arch_.rpm"

_arch="$(uname -m)"

_version="$(cat /etc/redhat-release  | cut -d ' ' -f 3 | cut -d '.' -f 1)"


if [ "$_arch" != "x86_64" -a "$_arch" != "i686" ]; then
  echo "Unknown architecture $_arch, aborting" >&2
  exit 1
fi

if [ "$_version" != "6" -a "$_version" != "5" ]; then
  echo "Unknow version $_version, aborting" >&2
  exit 1
fi 

_atrpms_rpm_url=${_atrpms_rpm_url//_arch_/$_arch}
_atrpms_rpm_url=${_atrpms_rpm_url//_version_/$_version}

_atrpms_rpm_file=${_atrpms_rpm_file//_arch_/$_arch}
_atrpms_rpm_file=${_atrpms_rpm_file//_version_/$_version}

echo "URL: "$_atrpms_rpm_url
echo "RPM: "$_atrpms_rpm_file

if [ "$USER" != "root" ]; then
  echo "SuperUser needed, login as root and rerun this script" >&2
  exit 1
fi

curl -s -L $_atrpms_rpm_url > $_atrpms_rpm_file

rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms

rpm -K $_atrpms_rpm_file

if [ "$?" -ne "0" ]; then 
  echo "Failed to verify .rpm file" >&2
  exit 1
fi

rpm -i $_atrpms_rpm_file

rpm -f $_atrpms_rpm_file
