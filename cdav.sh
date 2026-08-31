#!/bin/sh
# cdav.sh - All Rights Reserved. Copyleft 🄯 2026 Lai KamLeong

AUTH="user:password"
ROOT="https://kurio.infini-cloud.net"
BASE="/dav/"

_curl() {
  (echo "$2" | grep -q '^/') && url="${ROOT}$2" || url="${ROOT}${BASE}$2"
  echo "$url" ; eval "curl -s -u '$AUTH' -L $1 '$url'"
  ## must use eval above, otherwise it will not respect or parse the internal single quotes within $1 !!
}

if [ "$1" = "cat" ]; then

  _curl "" "$2"

elif [ "$1" = "get" ] || [ "$1" = "download" ]; then

  if (echo "$2" | grep -q '/$'); then
    echo "Folder '$2'"
    eval "'$0' ls '$2'" | grep -v '/$' | while IFS= read -r line; do
      # echo ">> $line"
      eval "'$0' get '$line'"
    done
  else
    filename="${2##*/}" ; echo -n "File '$filename' "
    [ -e "$filename" ] && read -p "already exists. Overwrite? (y/N): " CONFIRM || CONFIRM="y"
    [ "$CONFIRM" = "y" ] && _curl "-O" "$2" || echo "aborted."
  fi

elif [ "$1" = "ll" ]; then

  _curl "-X PROPFIND -H 'Depth: 0'" "$2"

elif [ "$1" = "ls" ]; then

  _curl "-X PROPFIND -H 'Depth: 1'" "$2" \
   | grep -oE '<[^:>]+:href>[^<]+' | sed -E 's/<[^>]+>//' \
   | sed -E "s|^${BASE}||" | sed '/^$/d' | grep . \
   | awk '{print ($0 ~ /\/$/ ? "1|" : "2|") $0}' \
   | sort -t'|' -k1,1n -k2,2 | cut -d'|' -f2-
  ## xmlstarlet sel -N d="DAV:" -t -m "//d:response" \
  ##  -v "d:href" -o " - " -v ".//d:getcontentlength" -n
  ## xmllint --xpath "//*[local-name()='href']/text()" -

elif [ "$1" = "put" ]; then

  _curl "-T -" "$2"

elif [ "$1" = "upload" ]; then

  [ -z "$2" ] && filepath="$0" || filepath="$2"
  [ -z "$3" ] && url="$BASE" || url="$3"
  (echo "$url" | grep -q '/$') && url="$url$(basename "$filepath")"
  echo "uploading [$filepath] to [$url] ..."
  cat "$filepath" | _curl "-i -T -" "$url" | head -n 3 ## -i shows response headers

elif [ "$1" = "append" ]; then

  ## (curl -s -u "$AUTH" -L "${ROOT}$2"; date ) | curl -s -u "$AUTH" -L  -T - "${ROOT}$2"
  ( _curl "" $2 ; cat ) | _curl "-T -" "$2"

elif [ "$1" = "mkdir" ]; then

  _curl "-i -X MKCOL" "$2" | head -n 3

elif [ "$1" = "rm" ]; then

  read -p "Proceed for deletion, are you sure?! (y/N): " CONFIRM
  [ "$CONFIRM" = "y" ] && _curl "-i -X DELETE" "$2" || echo "aborted."

else

  cdav="./cdav.sh"
  cat << EOT
 usage:
  $cdav ls
  $cdav get test.txt
  $cdav upload ./test.txt /dav/test.txt
  date | $cdav put test.txt
  date | $cdav append test.txt
EOT

fi
