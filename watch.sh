
function _watch() {
  l=`stty size |awk '{print int($1-2)}'`
  s=15
  cmdln="$*"
  if (echo "$cmdln" |grep -q '^-n'); then
    s=`echo "$cmdln" |sed -r 's/^-n *([0-9]+).*/\\1/'`
    cmdln=`echo "$cmdln" |sed -r 's/^-n *[0-9]+ *//'`
  fi
  while true; do
    clear
    x=`stty size |awk '{print int($2-35)}'`
    c=$(echo "$cmdln" |awk -v x="$x" '{print substr($0,1,x)}')
    d=`date +"%H:%M:%S"`
    echo "Every ${s}s: $c ... lastUpd: $d"
    echo
    eval "$cmdln" |head -n $l |head -c -1 # trim/remove last newline char
    sleep $s
  done
}
