@echo off
echo [PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITECTURE%]
echo [%0 %*]

if not "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto @continue
rem **relaunch**
echo relaunching [%0 %*] ...
start "cmd32" "%SystemRoot%\SysWOW64\cmd.exe" /c %0 %*
exit

:@continue
echo OK
pause
