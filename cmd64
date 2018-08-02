@echo off
echo [PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITECTURE%]
echo [%0 %*]

if not "%PROCESSOR_ARCHITECTURE%"=="x86" goto @continue
rem **relaunch**
echo relaunching [%0 %*] ...
start "cmd64" "%SystemRoot%\sysnative\cmd.exe" /c %0 %*
exit

:@continue
echo OK
pause
