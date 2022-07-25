# dynv6-updater for Windows
A PowerShell app to update your dynv6 ddns.

## First Step

Create your ddns host on https://dynv6.com/zones

Get your HTTP Token on https://dynv6.com/keys

## Running

Run this PowerShell script with 3 parameters:
  1. Your Host - Mandatory
  2. Yout Token - Mandatory
  3. Uptate Interval in seconds - If is null, default of 1800 (30 minutes) 

Example: powershell ./DynV6_Updater.ps1 myhost.v6.rocks blablablablablabla 600

Or you can simply use Start-DynV6_Updater.cmd batch file, dont forguet to edit and suppy your credentials.

You can create a link of Start-DynV6_Updater.cmd on "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" and the script is running on system startup.

##Working
After running the script, an update icon will appear in your system tray, hover over it and you will see the name "DynV6 Updater". Click on this icon with the right button, and you will see the possible options, which are self explanatory: Show Status, Sync Now and Exit. If you've come this far, you're smart enough to understand what they do.

Tested on Windows 8.1
