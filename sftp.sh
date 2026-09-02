#!/bin/sh
# sftp.sh - All Rights Reserved. Copyleft 🄯 2026 Lai KamLeong

# dropbear is designed to be a lightweight, minimal SSH server,
# it does not have a configuration file like OpenSSH's sshd_config,
# nor does it feature a built-in internal-sftp engine.
# sftp -P 22 user@127.0.0.1 # /usr/libexec/sftp-server not found
# sftp -s internal-sftp -P 22 user@127.0.0.1 ## failed
# below is an alternative to lftp -p 22 'fish://user:@127.0.0.1'
# FISH => Files transferred over SHell

HST=127.0.0.1
PRT=22
USR=user
OPT="-o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
(ssh -V 2>&1 | grep -iq "dropbear") && OPT='-y'

[ -e "sftp.h" ] && . ./sftp.h
echo "${USR}@${HST}:${PRT} => $@"

_ssh() {
  cmdln="ssh $OPT -p ${PRT} ${USR}@${HST} '$@'" #; echo "$cmdln"
  eval "$cmdln"
}
_fish() {
  fish="ssh $OPT -p ${PRT} ${USR}@${HST}" # Files transferred over SHell (FISH)
  [ "$1" = "get" ] && cmdln="$fish 'cat \"$2\"' > '$3'"  || cmdln="cat '$2' | $fish 'cat > \"$3\"'" ; echo "$cmdln"
  eval "$cmdln"
}
_scp() {
  f1="$2" ; f2="$3" ; r="${USR}@${HST}:"
  [ -z "$f2" ] && f2="${f1##*/}" ## f2=`basename "$f1"`
  (echo "$f2" | grep -q '/$') && f2="$f2${f1##*/}"
  [ "$OPT" = "-y" ] && opt2="-S ~/dbclient-y" || opt2="-O $OPT" ## dbclient -y "$@"
  if [ "$1" = "get" ]; then
    abortFileExists "$f2"
    f1="$r$f1"
  else
    echo "uploading [$1] to [$2] ... "
    abortFileExists "$f2" "remote"
    f2="$r$f2"
  fi
  cmdln="scp $opt2 -p -P ${PRT} '$f1' '$f2'" ; echo "$cmdln"
  eval "$cmdln"
}

abortFileExists() {
  if [ "$2" = "remote" ]; then
    EXS=`_ssh "test -e '$1' && echo 'Remote'"`
  elif [ -e "$1" ]; then
    EXS="Local"
  fi
  #[ -z "$EXS" ] && return 1 || return 0
  [ ! -z "$EXS" ] && read -p "$EXS file '$1' exists! Overwrite? (y/N): " CONFIRM || CONFIRM="y"
  [ "$CONFIRM" = "y" ] || { echo "aborted."; exit; }
  return 0
}

if [ "$1" = "sftp" ]; then

  cmdln="sftp $OPT -P $PRT ${USR}@${HST}" ; echo "$cmdln"
  eval "$cmdln"

elif [ "$1" = "ssh" ]; then

  cmdln="ssh $OPT -p ${PRT} ${USR}@${HST}" ; echo "$cmdln"
  eval "$cmdln"

elif [ "$1" = "get" ] || [ "$1" = "download" ]; then

  if (echo "$2" | grep -q '/$'); then
    echo "Folder '$2'"
    eval "'$0' ls -p '$2'" | grep -v '/$' | while IFS= read -r line; do
      # echo ">> $line"
      eval "'$0' get '$2$line' '$3'"
    done
  else
    #_fish "get" "$2" "$3"
    _scp "get" "$2" "$3"
  fi

elif [ "$1" = "put" ] || [ "$1" = "append" ]; then

  [ "$1" = "put" ] && cmdln="cat > '$2'" || cmdln="cat >> '$2'"
  if [ -t 0 ]; then ## Interactive terminal (No data redirected)
    abortFileExists "$2" "remote"
  #else # redirected, will not support custom prompt !
  fi
  _ssh "$cmdln"

elif [ "$1" = "upload" ]; then

  [ -z "$2" ] && f1="$0" || f1="$2"
  #_fish "put" "$f1" "$3"
  _scp "put" "$f1" "$3"

elif [ "$1" = "rm" ]; then

  read -p "Proceed for deletion, are you sure?! (y/N): " CONFIRM
  [ "$CONFIRM" = "y" ] && _ssh "$@" || echo "aborted."

#elif (echo ",ls,ll,pwd,mkdir,rmdir,cat," | grep -q ",$1,"); then
elif [ ! -z "$1" ]; then

  _ssh "$@"

else

  cat << EOT
 usage:
  $0 ls
  $0 get test.txt
  $0 upload ./test.txt /dav/test.txt
  date | $0 put test.txt
  date | $0 append test.txt
EOT

fi
