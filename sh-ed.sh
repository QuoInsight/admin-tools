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
    5,10p      # shows line#5-10
    5c <text>  # replace line#5 with <text>
    5i <text>  # insert <text> before line#5
    5a <text>  # append <text> after line#5
    5d         # delete line#5
    2,3d 5     # cut line#2-3 and paste after line#5
    / <regex>  # search for <regex>
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
    evl "ls -l '$filepath'" #evl "sed -n '1p' '$filepath' 2>&1"
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
        if [ "$c1" = "/" ]; then
          evl "sed -n '/$c2/{=;p}' '$filepath'" | paste -d'>' - - | sed 's|^\([0-9]*>\)\(.*\)|\1 \2|'
        elif (echo "$c1" | grep -q 'p$'); then
          c1="$(echo "$c1" | sed 's/.$//')"
          evl "sed -n '${c1}{=;p}' '$filepath'" | paste -d'>' - - | sed 's|^\([0-9]*>\)\(.*\)|\1 \2|'
        elif (echo "$c1" | grep -q 'd$') && [ -n "$c2" ]; then
          c1="$(echo "$c1" | sed 's/.$//')"
          evl "sed -i '${c1}{H;d}; ${c2}G' '$filepath'" ## this will actually adds a new blank line in between !
        elif [ -n "$c2" ]; then
          #evl "sed -i '$c1\\$c2' '$filepath' 2>/dev/null || test -s '$filepath' || echo '$c2' > '$filepath'"
          p1=$(evl "sed -i '$c1\\$c2' '$filepath' 2>&1")
          p1=$(printf "$p1 [$?]")
          if (printf "%b\0" "$p1" | grep -q '^sed:.*No such file.*\[.\]$'); then
            evl "test -s '$filepath' || echo '$c2' > '$filepath' && echo '>> new file created'"
          else
            printf "1> $p1\n"
          fi          
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
