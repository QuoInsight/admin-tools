#!/bin/sh
[ -z "$1" ] && {
  echo "usage: $0 <file>"
  exit
}
blksz=512
if [ -f "$1" ] && [ "`stat --printf='%s' "$1.dd0"`" = "$blksz" ]; then
  dd if="$1" of=/tmp/zero.dd1 bs=$blksz count=1 2>/dev/null \
    && cmp /tmp/zero.dd1 "$1.dd0" ; cmp_result="$?"
  [ "$cmp_result" = "0" ] && {
    echo "warning: file header matched/un-nullified, removing '$1.dd0'"
    rm -f "$1.dd0" ; rm /tmp/zero.dd1 ;
    exit
  }
  dd if=/dev/zero of=/tmp/zero.dd0 bs=$blksz count=1 2>/dev/null \
    && cmp /tmp/zero.dd0 /tmp/zero.dd1 ; cmp_result="$?"
  rm /tmp/zero.dd0 ; rm /tmp/zero.dd1
  echo "cmp_result=$cmp_result"
  [ "$cmp_result" != "0" ] && {
    echo "warning: file contains non-nullify header '$1'"
    exit
  }
  echo "restoring data from .dd0"
  set -e ## exit immediately if any command fails
  dd if="$1.dd0" of="$1" bs=$blksz count=1 conv=notrunc
  touch -r "$1.dd0" "$1"
  rm -f "$1.dd0"
  echo "done"
elif [ -f "$1.dd0" ]; then
  echo "warning: invalid file '$1.dd0'"
else
  echo "extracting data and creating .dd0 ..."
  set -e ## exit immediately if any command fails
  dd if="$1" of="$1.dd0" bs=$blksz count=1
  touch -r "$1" "$1.dd0"
  chmod -w "$1.dd0"
  dd if=/dev/zero of="$1" bs=$blksz count=1 conv=notrunc
  touch -r "$1.dd0" "$1"
  echo "done"
fi
