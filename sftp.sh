#!/bin/sh
# sftp.sh - All Rights Reserved. Copyleft 🄯 2026 Lai KamLeong

# dropbear is designed to be a lightweight, minimal SSH server,
# it does not have a configuration file like OpenSSH's sshd_config,
# nor does it feature a built-in internal-sftp engine.
# sftp -P 22 user@127.0.0.1 # /usr/libexec/sftp-server not found
# sftp -s internal-sftp -P 22 user@127.0.0.1 ## failed

HST=127.0.0.1
PRT=22
USR=user
OPT="-o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
(ssh -V 2>&1 | grep -iq "dropbear") && OPT='-y'

echo "${USR}@${HST}:${PRT} => $*"

_ssh() {
  eval "ssh $OPT -p ${PRT} ${USR}@${HST} '$1'"
}

_scp() {
  cmdln="scp $OPT -O -P ${PRT} '$1' '$2'" #; echo "$cmdln"
  eval "$cmdln"
}

isRemoteFileExists() {
  EXS=`_ssh "test -e '$1' && echo 'exists'"`
  [ -z "$EXS" ] && return 1 || return 0
}

if [ "$1" = "get" ] || [ "$1" = "download" ]; then

  if (echo "$2" | grep -q '/$'); then
    echo "Folder '$2'"
    eval "'$0' ls -p '$2'" | grep -v '/$' | while IFS= read -r line; do
      # echo ">> $line"
      eval "'$0' get '$2$line'"
    done
  else
    filename="${2##*/}" ; echo -n "Local File: '$filename' "
    [ -e "$filename" ] && read -p "already exists. Overwrite? (y/N): " CONFIRM || CONFIRM="y"
    [ "$CONFIRM" = "y" ] && _scp "${USR}@${HST}:$2" "$filename" || echo "aborted."
  fi

elif [ "$1" = "put" ] || [ "$1" = "append" ]; then

  [ "$1" = "put" ] && cmdln="cat > '$2'" || cmdln="cat >> '$2'"
  if [ -t 0 ]; then ## Interactive terminal (No data redirected)
    echo -n "Remote File: '$2' "
    isRemoteFileExists "$2" && EXS="exists"
    echo "$EXS"
    [ ! -z "$EXS" ] && read -p "Overwrite? (y/N): " CONFIRM || CONFIRM="y"
    [ "$CONFIRM" = "y" ] && _ssh "$cmdln" || echo "aborted."
  else ## redirected, will not support custom prompt !
    _ssh "$cmdln"
  fi

elif [ "$1" = "upload" ]; then

  [ -z "$2" ] && filepath="$0" || filepath="$2"
  [ -z "$3" ] && remotefile=$(basename "$filepath") || remotefile="$3"
  (echo "$3" | grep -q '/$') && remotefile="$3$remotefile"

  echo -n "uploading [$filepath] to [$remotefile] ... "
  isRemoteFileExists "$remotefile" && EXS="Remote file exists!"
  echo "$EXS"
  [ ! -z "$EXS" ] && read -p "Overwrite? (y/N): " CONFIRM || CONFIRM="y"
  [ "$CONFIRM" = "y" ] && _scp "$filepath" "${USR}@${HST}:$remotefile" || echo "aborted."

elif [ "$1" = "rm" ]; then

  read -p "Proceed for deletion, are you sure?! (y/N): " CONFIRM
  [ "$CONFIRM" = "y" ] && _ssh "$*" || echo "aborted."

#elif (echo ",ls,ll,pwd,mkdir,rmdir,cat," | grep -q ",$1,"); then
elif [ ! -z "$1" ]; then

  _ssh "$*"

else

  sftp="./sftp.sh"
  cat << EOT
 usage:
  $sftp ls
  $sftp get test.txt
  $sftp upload ./test.txt /dav/test.txt
  date | $sftp put test.txt
  date | $sftp append test.txt
EOT

fi
