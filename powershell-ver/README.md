# dynv6-updater for Windows
A PowerShell app to update your dynv6 ddns.

## First Step

Create your ddns host on https://dynv6.com/zones

Get your HTTP Token on https://dynv6.com/keys

## Running

Edit the config.txt file with your host, token and refresh interval, in json format

Start the app via the Start-DynV6 Update.cmd script for better compatibility

An icon will be created in the system tray, right click to manually refresh, display information or exit.

You can create a link of Start-DynV6_Updater.cmd on "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" and the script will running on system startup.

### Tested on Windows 8.1 / 10 / 11
