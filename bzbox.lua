#!/usr/bin/lua

_,_,Ver1,Ver2 = string.find(_VERSION, "Lua (%d+)%.(%d+)")
_LuaVersionNumber = tonumber(Ver1.."."..Ver2);
_,_,_LuaScriptSource = debug.getinfo(1).source:find("^@?.-([^\\/]+)$")
_SupportedFunctions = {"bc", "sleep", "usleep"}
_UnsupportedFunctions = {
  "[, [[, ar, arp, ash, awk, base64, basename, beep, ...",
  "\n    ..., whoami, whois, xargs, xz, xzcat, yes, zcat"
}

--[[
ln -s /root/bzbx.lua /usr/bin/bc
    [, [[, ar, arp, ash, awk, base64, basename, beep, 
    blkid, blockdev, bootchartd, bunzip2, bzcat, bzip2, 
    cal, cat, catv, chat, chattr, chgrp, chmod, chown, 
    chpst, chroot, chrt, chvt, cksum, clear, cmp, comm, 
    cp, cpio, crond, crontab, cttyhack, cut, dc, dd, 
    deallocvt, depmod, devmem, diff, dirname, dmesg, 
    dnsd, dos2unix, dpkg, dpkg-deb, du, dumpkmap, echo, 
    ed, egrep, env, envdir, envuidgid, expand, expr, 
    fakeidentd, false, fatattr, fbset, fbsplash, 
    fdflush, fdformat, fdisk, fgconsole, fgrep, find, 
    findfs, flash_lock, flash_unlock, flashcp, flock, 
    fold, free, freeramdisk, fstrim, ftpd, ftpget, 
    ftpput, fuser, getopt, grep, gunzip, gzip, hd, 
    hdparm, head, hexdump, httpd, hwclock, ifconfig, 
    ifdown, ifup, init, inotifyd, insmod, install, 
    iostat, ip, ipaddr, ipcalc, iplink, iproute, 
    iprule, iptunnel, less, linuxrc, ln, loadkmap, 
    losetup, ls, lsattr, lsmod, lsof, lspci, lsusb, 
    lzcat, lzma, lzop, lzopcat, makedevs, man, md5sum, 
    mesg, mkdir, mkfifo, mknod, mkswap, mktemp, 
    modinfo, modprobe, more, mpstat, mv, nanddump, 
    nbd-client, nc, netstat, nice, nmeter, nohup, od, 
    openvt, patch, pidof, ping, pipe_progress, pmap, 
    powertop, printenv, printf, ps, pscan, pstree, pwd, 
    pwdx, raidautorun, rdev, readlink, readprofile, 
    realpath, renice, reset, resize, rev, rm, rmdir, 
    rmmod, route, rpm, rpm2cpio, rtcwake, run-parts, 
    runsv, runsvdir, rx, script, scriptreplay, sed, 
    seq, setconsole, setkeycodes, setlogcons, 
    setserial, setsid, setuidgid, sh, sha1sum, 
    sha256sum, sha3sum, sha512sum, showkey, shuf, 
    sleep, smemcap, softlimit, sort, split, 
    start-stop-daemon, strings, stty, sum, sv, svlogd, 
    switch_root, sync, sysctl, tac, tail, tar, tcpsvd, 
    tee, test, tftp, tftpd, time, timeout, top, touch, 
    tr, traceroute, true, truncate, ttysize, tunctl, 
    tune2fs, udhcpc, udpsvd, uevent, uname, uncompress, 
    unexpand, uniq, unix2dos, unlink, unlzma, unlzop, 
    unxz, unzip, uptime, usleep, uudecode, uuencode, 
    vconfig, vi, volname, watch, wc, wget, which, 
    whoami, whois, xargs, xz, xzcat, yes, zcat
--]]

function about()
  print(string.format([[

A simple Lua script emulating some BusyBox functions/commands

Usage: bzbx.lua [function [arguments]...]
   or: bzbx.lua --list[-full]
   or: bzbx.lua --install [-s] [DIR]
   or: function [arguments]...

BusyBox is a multi-call binary that combines many common Unix
utilities into a single executable.  Most people will create a
link to busybox for each function they wish to use and BusyBox
will act like whatever it was invoked as.

Currently defined functions:
  %s

  below functions are not (yet) implemented:
    %s
]],
    table.concat(_SupportedFunctions, ", "),
    table.concat(_UnsupportedFunctions, ", ")
  ))
  print(_VERSION.." ["..arg[-1].."] "..debug.getinfo(1).source)
  for i = 0, #arg do
    print(i .. ": " .. arg[i])
  end
  print()
end

function install(argv)
  print(">> creating symlinks ...")
  src = _LuaScriptSource
  for i = 1, #_SupportedFunctions do
    fnc = _SupportedFunctions[i]
    cmd = 'ln -s '..src..' /usr/bin/'..fnc
    print(i..": "..cmd)
    --os.execute(cmd)
  end
  print(">> Done\n")
end

function bc(argv)
  a = (argv==nil and io.read() or argv) --io.read("*all")
  a = "return "..a -- a = math.eval(a)
  a = (_LuaVersionNumber>=5.2 and load(a) or loadstring(a))
  r = string.format("%.2f",a())
  r = string.gsub(r, "%.?0+$", "")
  return r
end

function sleep(argv)
  if argv==nil then argv=1 end
  local socket = require 'socket'
  socket.sleep(argv)
end

function usleep(argv)
  if argv==nil then argv=1 else argv=argv/1000 end
  sleep(argv)
end

-- main() --

_,_,arg[0] = string.find(arg[0], "([^\\/]+)$")
supportedFunctions = ","..table.concat(_SupportedFunctions, ",")..","
if supportedFunctions:find(","..arg[0]..",") == nil then
--if string.find(arg[0], "[\\/]?"..(_LuaScriptSource:gsub("%.","%%.")).."$") ~= nil then
  -- table.remove(arg, 1) -- this not working correctly for arg[0] !!
  for i = 0, (#arg-1) do arg[i]=arg[i+1] end; table.remove(arg, #arg)
  _,_,arg[0] = string.find(arg[0], "([^\\/]+)$")
end

about()

if arg[0]=="bc" then
  --io.write(">> ")
  print( bc() );  os.exit()
elseif arg[0]=="sleep" then
  sleep(arg[1]);  os.exit()
elseif arg[0]=="usleep" then
  usleep(arg[1]);  os.exit()
elseif arg[0]=="--install" then
  install(arg[1]);  os.exit()
end

about()
