# -*- coding: utf-8 -*-
# line editor by QuoInsight (2021)

import sys
def printV(v, end="\n") :
  s = str(v).encode("utf8", errors='backslashreplace').decode(sys.stdout.encoding)
  print( s )
#

import os
def loadFile(filepath) :
  printV("##> currentFile: " + filepath)
  if os.path.isfile(filepath) :
    with open(filepath, 'r',
      encoding="utf8", errors="replace"
    ) as f: lines=f.readlines() # txt=f.read()
  else :
    lines = []
  #
  l = len(lines)
  print("##> 1/" + str(l) + ": " + (lines[0] if (l>0) else "\n"))
  return lines
#

def prnLine(lines, idx) :
  txt = ( lines[idx] if (len(lines)>idx) else "<null>\n" )
  #printV(str(idx+1) + ": " + txt, end='')
  printV(txt, end='')
#

def addLine(lines, idx, txt) :
  l = len(lines)
  if (idx > l) :
    for x in range(l, idx): lines.append("\n")
    lines.append(txt)
  else :
    lines.insert(idx, txt);
  #
  return lines
#

def cmdPrompt(pLines, pIdx) :
  global filepath, lines, idx
  cmd = input("^" + str(pIdx+1) + "> ").strip()
  ## printV("#" + cmd + "#")
  if (cmd=='?') :
    printV("""##> list of commands:
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
    printV("##> currentFile: " + filepath)
    printV("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
  elif (cmd=='rr' or cmd.startswith('rr ')) :
    confirmed = input("!! WARNING !! discard & reload? [Y/n]> ").strip().lower()
    if not(confirmed=="" or confirmed=="y") : return cmdPrompt(pLines, pIdx)
    if (cmd=='rr') :
      pass
    elif (cmd=='rr ?') :
      filepath = input("filename> ").strip()
    else :
      filepath = cmd[3:]
    #
    try :
      lines = loadFile(filepath);
    except Exception as e:
      printV("!! ERROR !! " + str(e))
      lines = []
    #
    idx = 0
  elif (cmd=='ll') :
    # printV(''.join(lines))
    i = 0
    for line in lines :
      i += 1;  printV(str(i) + ": " + line.strip())
    #
  elif (cmd=='m') :
    for line in lines[idx:idx+10] :
      printV(line.strip())
    #
  elif (cmd=='l') :
    printV("##> currentFile: " + filepath)
    printV("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
    prnLine(lines, idx)
  elif (cmd=='i' or cmd=='O') or (cmd=='a' or cmd=='o') :
    l = len(lines)
    if (cmd=='a' or cmd=='o') :
      if (l > 0) : idx += 1
    #
    lines = addLine(
      lines, idx, (input(str(idx+1) + ": ") + "\n")
    )

    if (cmd=='O' or cmd=='o') :
      print("[multi-line mode. \\z to end]")
      while True:
        tmp = input(str(idx+2) + ": ")
        if (tmp.strip()=="\\z") : break
        idx += 1
        lines = addLine(lines, idx, tmp)
      #
    #
  elif (cmd=='r') :
    prnLine(lines, idx)
    for x in range(len(lines), idx+1): lines.append("\n") #if (idx >= len(lines))
    lines[idx] = input(str(idx+1) + ": ") + "\n"
  elif (cmd=='d') :
    l = len(lines)
    if (idx==0 and l<=1) :
      lines = []
      printV("#> all deleted")
    elif (idx < l) :
      t = lines[idx]
      lines.pop(idx);
      if (idx > 0 and idx > l-2) :
        printV("#deleted#> " + t, end='')
        idx -= 1
      else :
        printV("#deleted#> " + t, end='')
      #
      prnLine(lines, idx)
    else :
      idx = l-1
    #
  elif (cmd=='w') :
    printV("##> currentFile: " + filepath)
    printV("##> lineIndex: " + str(idx+1) + "/" + str(len(lines)))
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
      printV("##> saved.")
    except Exception as e:
      printV("!! ERROR !! " + str(e))
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
        printV("##> invalid command !")
        return cmd
      #
    #
    prnLine(lines, idx)
  elif (cmd=='q') :
    confirmed = input("!! WARNING !! quit without saving? [Y/n]> ").strip().lower()
    if not(confirmed=="" or confirmed=="y") : return cmdPrompt(pLines, pIdx)
  elif (cmd=='q!' or cmd=='Q') :
    return "q"
  else :
    printV("##> invalid command !")
  #
  return cmd
#

def main(argv) :
  _thisScript_ = argv[0]  ## __file__
  global filepath, lines, idx
  filepath = ( argv[1] if (len(argv)>1) else r"B:\a.txt" );
  lines = loadFile(filepath);  idx = 0;
  while ( cmdPrompt(lines, idx)!="q" ) :
    pass
  #
#

global filepath, lines, idx

if __name__ == '__main__':
  main(sys.argv)
#
