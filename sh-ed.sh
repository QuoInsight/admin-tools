#!/bin/sh
#while true; do
#  printf "# "
#  read -r cmdln
#  [ "$cmdln" = "exit" ] && exit
#  printf "You entered: %s\n" "$cmdln"
#done

evl() {
  #eval "$@" ; return
  cmdln="$(printf '%s\n' "$*"|sed -e 's|^sed -n\(.*\)|echo;sed -n\1|' -e 's|\\|\\\\|g')"
  curl -s -L -d "$cmdln" 'http://127.0.0.1/cgi-bin/sh'
}

if [ "$1" = "sed" ] && [ $# -le 2 ]; then
  sed_hlp=$(cat <<EOT
    5,10p     # shows line# 5 to 10
    5c <text> # replace line#5 with <text>
    5i <text> # insert <text> before line#5
    5a <text> # append <text> after line#5
    5d        # delete line#5
EOT
)
  if [ "$2" = "" ] || [ "$2" = "?" ]; then
    cat <<EOT
  sed <filepath> # start interactive mode
$sed_hlp
EOT
  else
    filepath="$2"
    #(echo "$filepath" | grep -q '^/tmp/') || filepath="/tmp/$filepath"
    #filepath="$(echo "$filepath"|sed 's|//|/|g')"
    evl "ls -l '$filepath'"
    p1=$(evl "sed -n '1p' '$filepath' 2>&1")
    p1=$(printf "$p1 [$?]")
    printf "1> $p1\n"
    if (printf "%b\0" "$p1" | grep -q '^sed:.*No such file.*\[.\]$'); then
      touch "$filepath" && echo ">> new file created"
    fi
    while true; do
      printf "[$filepath] # "
      read -r cmdln
      if [ "$cmdln" = "?" ]; then
        echo "$sed_hlp"
      elif [ "$cmdln" = "exit" ]; then
        exit
      elif [ -n "$cmdln" ]; then
        ## set -- $cmdln ## will not preserve extra spaces
        c1="${cmdln%% *}" ; c2="${cmdln#* }" ## split only at 1st space, will give the entire string when there is no space!! ## "$(echo "$cmdln" | cut -d' ' -f1)" ; "$(echo "$cmdln" | cut -d' ' -f2-)"
        [ "$c2" = "$cmdln" ] && c2="" ## no better way for this !!?
        if [ -n "$c2" ]; then
          evl "test -s '$filepath' && sed -i '$c1\\$c2' '$filepath' || echo '$c2' > '$filepath'"
        elif ( echo "$c1" | grep -q 'p$' ); then
          n=$(echo "$c1" | sed 's/.$//')
          evl "sed -n '${n}{=;p}' '$filepath'" | paste -d'>' - - | sed 's|^\([0-9]*>\)\(.*\)|\1 \2|'
        else
          evl "sed -i '$cmdln' '$filepath'"
        fi
      fi
    done
  fi
  exit
fi

curl -s -L -d "$*" 'http://127.0.0.1/cgi-bin/sh'
exit
