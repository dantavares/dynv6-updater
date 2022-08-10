@echo off

set host=my-dynv6host-here
set token=my-token-here
set interval=1800

start /min powershell ./DynV6_Updater.ps1 %host% %token% %interval%
