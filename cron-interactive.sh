#!/bin/sh

while true; do
  date +"%H %M %S" | {
    read -r hh mm ss
    printf "\r%s" "$ss"
    if [ "$ss" = "00" ]; then
      ~/run-every-minute.sh
    fi
  }
  sleep 1
done
