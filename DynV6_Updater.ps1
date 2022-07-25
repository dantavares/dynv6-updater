[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null

$hostname = $args[0]
$token =  $args[1]
$interval = $args[2]

if ( [string]::IsNullOrEmpty( $args[0] ) ) { Stop-Process $pid }
if ( [string]::IsNullOrEmpty( $args[1] ) ) { Stop-Process $pid }
if ( [string]::IsNullOrEmpty( $args[2] ) ) { $interval = 1800 } #Default 30 minutes interval

# ----------------------------------------------------
# Extract "Sync" Icon from Shell32.dll
# ----------------------------------------------------		
$exicon = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace System {
    public class IconExtractor {
        public static Icon Extract(string file, int number, bool largeIcon) {
	        IntPtr large;
	        IntPtr small;
	        ExtractIconEx(file, number, out large, out small, 1);
	        try {
	            return Icon.FromHandle(largeIcon ? large : small);
	        }
	        catch {
	            return null;
	        }
	    }
	    [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
	    private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
	 }
}
"@
Add-Type -TypeDefinition $exicon -ReferencedAssemblies System.Drawing
$icon = [System.IconExtractor]::Extract("shell32.dll", 238, $true)

# ----------------------------------------------------
# Main Sync Function and Sync first time
# ----------------------------------------------------		
function Sync {
    $Response4 = Invoke-WebRequest -UseBasicParsing -URI "http://ipv4.dynv6.com/api/update?hostname=$hostname&token=$token&ipv4=auto"
    $Response6 = Invoke-WebRequest -UseBasicParsing -URI "http://ipv6.dynv6.com/api/update?hostname=$hostname&token=$token&ipv6=auto&ipv6prefix=auto"
    $Date = Get-Date -UFormat "%d/%m/%y %R"
    $Global:Tipicon = "Info"

    if ([string]::IsNullOrEmpty($Response4)) {
        $Global:tipicon = "Error"
        $Response4 = "Error! Check your credentials or Internet Connection"
    }

    if ([string]::IsNullOrEmpty($Response6)) {
        $Global:tipicon = "Error"
        $Response6 = "Error! Check your credentials or IPv6 Status"
    }

    $Global:Response = "Last Update: $Date`r`nIPv4: $Response4 `r`nIPv6: $Response6"
}
Sync

# ----------------------------------------------------
# Timer event to periodically sync at specified interval
# ----------------------------------------------------		
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $interval * 1000
$timer.Add_Tick({Sync})
$timer.Start()

# ----------------------------------------------------
# Add the systray menu
# ----------------------------------------------------		
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "DynV6 Updater"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true

$Show_Status = New-Object System.Windows.Forms.MenuItem
$Show_Status.text = "Show Status"

$Sync_Now = New-Object System.Windows.Forms.MenuItem
$Sync_Now.Text = "Sync Now"

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu
$Main_Tool_Icon.ContextMenu.MenuItems.AddRange($Show_Status)
$Main_Tool_Icon.ContextMenu.MenuItems.AddRange($Sync_Now)
$Main_Tool_Icon.ContextMenu.MenuItems.AddRange($Menu_Exit)
$Main_Tool_Icon.BalloonTipTitle = "DynV6 Status"

# ---------------------------------------------------------------------
# Action after clicking on Show Status
# ---------------------------------------------------------------------
$Show_Status.Add_Click({	
    $Main_Tool_Icon.BalloonTipIcon = $Global:Tipicon
    $Main_Tool_Icon.BalloonTipText = $Global:Response
    $Main_Tool_Icon.ShowBalloonTip(1000)
})

# ---------------------------------------------------------------------
# Action after clicking on Sync Now
# ---------------------------------------------------------------------
$Sync_Now.Add_Click({
    Sync
})

# ---------------------------------------------------------------------
# Action on close 
# ---------------------------------------------------------------------
# When Exit is clicked, close everything and kill the PowerShell process
$Menu_Exit.add_Click({
	$Main_Tool_Icon.Dispose()
	Stop-Process $pid
})

# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Force garbage collection just to start slightly lower RAM usage.
[System.GC]::Collect()

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)
