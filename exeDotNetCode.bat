@echo off
rem set pshcmd="Add-Type -ReferencedAssemblies (\"System.Windows.Forms\") -Path \"%1\"; [myNameSpace.myMainClass]::Main(\"\")"
rem ** To quote verbatim strings in Powershell, just use single quotes **
set pshcmd=$WarningPreference='Continue'
set pshcmd=%pshcmd%; $refAssy=@('System.Web.Extensions','System.Windows.Forms')
set pshcmd=%pshcmd%; Add-Type -IgnoreWarnings -WarningAction 'Continue' -ReferencedAssemblies $refAssy -Path '%1'
set pshcmd=%pshcmd%; $args=( @() ); [myNameSpace.myMainClass]::Main($args)
start notepad %1

:@begin
echo starting .... powershell.exe -noprofile -command %pshcmd%
pause

powershell.exe -noprofile -command %pshcmd%
echo.
goto @begin
