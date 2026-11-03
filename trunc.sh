#!/bin/sh

echo ""
tail -n 10 "$1" || exit

[ -z "$2" ] && n="200" || n="$2"
echo ""
echo ">> truncate file and keep only last $n lines, are you sure?"
echo ">> <ctrl-c> to abort, or <enter> to continue ..."
read
echo "OK"

tmpfile="/tmp/~trunc$$.tmp"
tail -n "$n" "$1" > "$tmpfile" && cat "$tmpfile" > "$1" && rm "$tmpfile"
echo "Done
