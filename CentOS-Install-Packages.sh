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


_file=
_repos=
_print=

_options=":f:r:ph"

usage() { 
  echo """Usage: $0 -f packages-file [-r enablerepo] -p -h
    -f  - file containing selected packages, all lines starting with # are ignored, 
          everything after # sign is ignored
    -r  - yum --enablerepo option
    -p  - just print yum command
    -h  - this help
""" >&2
}

while getopts $_options _option; do 
  case $_option in 
    f )
      _file=$OPTARG
      ;;
    r )
      _repos=$OPTARG
      ;;
    p )
      _print="t"
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      echo "Error. Unknown option: -$OPTARG" >&2
      exit 1
      ;;
    : )
      echo "Error. Missing option argument for -$OPTARG" >&2
      exit 1
      ;;
  esac 
done

if [ -z "$_file" ]; then
  echo "Packages file $_file not specified" >&2
  exit 1
fi

if [ ! -e "$_file" ]; then
  echo "Packages file $_file does not exist" >&2
  exit 1
fi

_command="yum -y "

if [ -n "$_repos" ]; then
  _command=$_command" --enablerepo="$_repos
fi

_command=$_command" install "

while read _line; do
  if [[ "$_line" =~ "^#.*" ]]; then
    continue
  fi

  _line=${_line//  / }
  _line=${_line%%#*}

  if [ -z "$_line" ]; then
    continue
  fi

  _command=$_command" "$_line" "

done < $_file

echo $_command

if [ -n "$_print" ]; then
  echo "Will not execute yum command" >&2
  exit 0
fi

$_command
