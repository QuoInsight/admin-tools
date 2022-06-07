#!/usr/bin/lua
-- opkg install luasocket
-- https://github.com/QuoInsight/admin-tools/blob/master/bzbox.lua

_,_,Ver1,Ver2 = string.find(_VERSION, "Lua (%d+)%.(%d+)")
_LuaVersionNumber = tonumber(Ver1.."."..Ver2);
_,_,_LuaScriptSource = debug.getinfo(1).source:find("^@?(.+)") -- "^@?.-([^\\/]+)$"
_SupportedFunctions = {"bc", "cronchk", "install", "realpath", "sleep", "usleep"}
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

function _about()
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

function _exeCmd(cmdln)
  local file = assert(io.popen(cmdln, 'r'))
  local output = file:read('*all')
  file:close()
  output = string.gsub(output, "^%s*(.-)%s*$", "%1") --trim
  return output
end

function _realpath(filepath)
  if package.config:sub(1,1)=="/" then -- https://stackoverflow.com/a/14425862
    -- https://stackoverflow.com/a/31605674
    if filepath==nil or filepath=="" or filepath=="." then
      return _exeCmd("pwd")
    elseif filepath==".." then
      return _exeCmd('echo "$(cd ..; pwd)"')
    else
      cmdln = 'echo "$(cd "$(dirname "'..filepath..'")"; pwd)/$(basename "'..filepath..'")"'
      return _exeCmd(cmdln)
    end
  else
    return filepath
  end
end

function install(arg)
  print(">> creating symlinks ...")
  src = _realpath(_LuaScriptSource)
  for i = 1, #_SupportedFunctions do
    fnc = _SupportedFunctions[i]
    if fnc ~= "install" then
      cmd = 'ln -s '..src..' /usr/bin/'..fnc
      print(i..": "..cmd)
      --os.execute(cmd)
    end
  end
  print(">> Done\n")
end

function bc(arg)
  a = (arg[1]==nil and io.read() or arg[1]) --io.read("*all")
  a = "return "..a -- a = math.eval(a)
  a = (_LuaVersionNumber>=5.2 and load(a) or loadstring(a))
  r = string.format("%.2f",a())
  r = string.gsub(r, "%.?0+$", "")
  print( r )
end

function cronchk(arg)
  function _roundMinutes(t, m)
    intInterval = 60 * m
    return math.floor(t/intInterval + 0.5) * intInterval;
  end

  function _matchCronParam(cfgParam, actVal)
    if cfgParam==nil or cfgParam==''
     or cfgParam=='*' or cfgParam=='a' or cfgParam=='x'
    then return true end
    for s in string.gmatch(cfgParam, '([^,]+)') do
      p = string.find(s, "-")
      if p==nil then
        s = tonumber(s) -- tostring()
        if actVal==s then return true end
      else
        s1 = tonumber(string.sub(s,1,p-1))
        s2 = tonumber(string.sub(s,p+1,#s))
        if (actVal>=s1 and actVal<=s2)
         then return true end
      end
    end
    return false
  end

  local t = os.time() -- print( os.date("%c", t) )
  t = os.date("*t", _roundMinutes(t, 5))
  print( t.year.."-"..t.month.."-"..t.day.." ("..t.wday..") "..t.hour..":"..t.min..":"..t.sec )

  print(arg[1])
  local f1 = io.open(arg[1],"r")
  if f1~=nil then
    repeat
      line = f1:read()
      if line==nil then break end
      print(line)
      local l_arg = {};
      for s in string.gmatch(line, '([^ ]+)') do
        table.insert(l_arg, s)
      end
      if ( l_arg[1]~="#"
       and _matchCronParam(l_arg[1], t.min)
       and _matchCronParam(l_arg[2], t.hour)
       and _matchCronParam(l_arg[3], t.day)
       and _matchCronParam(l_arg[4], t.month)
       and _matchCronParam(l_arg[5], t.wday-1)
      ) then
        print("OK")
        os.exit(0)
      end
    until (line==nil)
    io.close(f1)
  else
    if ( _matchCronParam(arg[1], t.min)
     and _matchCronParam(arg[2], t.hour)
     and _matchCronParam(arg[3], t.day)
     and _matchCronParam(arg[4], t.month)
     and _matchCronParam(arg[5], t.wday-1)
    ) then
      print("OK")
      os.exit(0)
    end
  end
  os.exit(1)
end

function realpath(arg)
  print( _realpath(arg[1]) )
end

function sleep(arg)
  if arg[1]==nil then arg[1]=1 end
  local socket = require 'socket'
  socket.sleep(arg[1])
end

function usleep(arg)
  if arg[1]==nil then arg[1]=1 else arg[1]=arg[1]/1000 end
  sleep(arg)
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
if supportedFunctions:find(","..arg[0]..",") ~= nil then
  _G[arg[0]](arg);  os.exit()
end

_about()
