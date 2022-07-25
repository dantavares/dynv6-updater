# dynv6-updater
A PowerShell app to update your dynv6 ddns.

Create your free ddns host on https://dynv6.com

Get your token on https://dynv6.com/keys

Run this PowerShell script with 3 parameters:
1- Your Host - Mandatory
2- Yout Token - Mandatory
3- Uptate Interval in seconds - If is null, default of 1800 (30 minutes) 

Example: powershell ./DynV6_Updater.ps1 myhost.v6.rocks blablablablablabla 600

Or you can simply use Start-DynV6_Updater.cmd batch file, dont forguet to edit and suppy your credentials.

You can create a link of Start-DynV6_Updater.cmd on "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" and the script is running on system startup.

Tested on Windows 8.1
