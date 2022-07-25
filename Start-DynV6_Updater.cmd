@echo off

set host=danielrteste.dynv6.net
set token=Zr1c2m-8UM5nfyyJtZWPLxrHnCP8CC
set interval=1800

start /min powershell ./DynV6_Updater.ps1 %host% %token% %interval%