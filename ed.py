# -*- coding: utf-8 -*-
# line editor by Lai KamLeong (2021)

import sys
def printV(v) :
  s = str(v).encode("utf8", errors='replace').decode(sys.stdout.encoding)
  print( s )
#

import os
def loadFile(filepath) :
  print(filepath)
  if os.path.isfile(filepath) :
    with open(filepath, 'r') as f: lines=f.readlines() # txt=f.read()
  else :
    lines = []
  #
  return lines
#

def prnLine(lines, idx) :
  txt = ( lines[idx] if (len(lines)>idx) else "<null>\n" )
  #print(str(idx+1) + ": " + txt, end='')
  print(txt, end='')
#

def cmdPrompt(pLines, pIdx) :
  global filepath, lines, idx
  cmd = input("^" + str(pIdx+1) + "> ").strip()
  ## print("#" + cmd + "#")
  if (cmd=='?') :
    print("""##> list of commands:
  ?          display this help message
  q          quit
  w          save to file/disk
  rr         reload from file/disk
  ll         print all lines
  m          print next 10 lines
  l          show current file & line
  <num>      show specific line
  ^          show first line
  $          show last line
  k          show previous line
  j,<enter>  show next line
  i,O        insert new line
  a,o        append new line
  r          edit/replace current line
  d          delete current line
""")
    print("##> currentFile: " + filepath)
    print("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
  elif (cmd=='rr') :
    lines = loadFile(filepath);
    idx = 0;  prnLine(lines, idx)
  elif (cmd=='ll') :
    # print(''.join(lines))
    i = 0
    for line in lines :
      i += 1;  print(str(i) + ": " + line.strip())
    #
  elif (cmd=='m') :
    for line in lines[idx:idx+10] :
      print(line.strip())
    #
  elif (cmd=='l') :
    print("##> currentFile: " + filepath)
    print("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
    prnLine(lines, idx)
  elif (cmd=='i' or cmd=='O') or (cmd=='a' or cmd=='o') :
    l = len(lines)
    if (cmd=='a' or cmd=='o') :
      if (l > 0) : idx += 1
    #
    if (idx > l) :
      for x in range(len(lines), idx+1): lines.append("\n")
    else :
      lines.insert(idx, "\n");
    #
    lines[idx] = input(str(idx+1) + ": ") + "\n"
  elif (cmd=='r') :
    prnLine(lines, idx)
    for x in range(len(lines), idx+1): lines.append("\n") #if (idx >= len(lines))
    lines[idx] = input(str(idx+1) + ": ") + "\n"
  elif (cmd=='d') :
    l = len(lines)
    if (idx==0 and l<=1) :
      lines = []
      print("##> all deleted")
    elif (idx < l) :
      t = lines[idx]
      lines.pop(idx);
      if (idx > 0 and idx > l-2) :
        print("##deleted##> " + t, end='')
        idx -= 1
      else :
        print("##deleted##> " + t, end='')
      #
      prnLine(lines, idx)
    else :
      idx = l-1
    #
  elif (cmd=='w') :
    print("##> currentFile: " + filepath)
    print("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
    if (filepath=="") : filepath = input("filename> ").strip()
    confirmed = input("!! WARNING !! save & overwrite? [Y/n/?]> ").strip().lower()
    if (confirmed=="?") : 
      filepath = input("filename> ").strip()
    elif not(confirmed=="" or confirmed=="y") :
      return cmdPrompt(pLines, pIdx)
    #
    try :
      with open(filepath, 'w') as f :
        f.writelines(lines)
        f.close()
      #
      print("##> saved.")
    except :
      print("!! ERROR !! ", sys.exc_info()[0])
    #
  elif (cmd=='^' or cmd=='$' or cmd=='k' or cmd=='j' or cmd=='' or cmd.isdigit()) :
    if (cmd=='^') :
      idx = 0
    elif (cmd=='$') :
      l = len(lines)
      if (l > 0) : idx = l-1
    elif (cmd=='k') :
      if (idx > 0): idx -= 1
    elif (cmd=='j' or cmd=='') :
      idx += 1;
    else :
      i = int(cmd)
      if (i > 0):
        idx = i - 1
      else :
        print("##> invalid command !")
        return cmd
      #
    #
    prnLine(lines, idx)
  elif (cmd=='q') :
    confirmed = input("!! WARNING !! quit without saving? [Y/n]> ").strip().lower()
    if not(confirmed=="" or confirmed=="y") : return cmdPrompt(pLines, pIdx)
  elif (cmd=='q!' or cmd=='Q') :
    pass
  else :
    print("##> invalid command !")
  #
  return cmd
#

def main(argv) :
  _thisScript_ = sys.argv[0]  ## __file__
  global filepath, lines, idx
  filepath = ( sys.argv[1] if (len(sys.argv)>1) else r"" );
  lines = loadFile(filepath);
  idx = 0;  prnLine(lines, idx)
  while ( cmdPrompt(lines, idx)!="q" ) :
    pass
  #
#

global filepath, lines, idx

if __name__ == '__main__':
  main(sys.argv)
#
