[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.drawing

$jsondata = Get-Content -Raw config.txt | ConvertFrom-Json

$hostname = $jsondata.hostname
$token =  $jsondata.token
$interval = $jsondata.interval

if ( [string]::IsNullOrEmpty( $hostname ) ) { Stop-Process $pid }
if ( [string]::IsNullOrEmpty( $token ) ) { Stop-Process $pid }
if ( [string]::IsNullOrEmpty( $interval ) ) { $interval = 1800 } #Default 30 minutes interval

# ----------------------------------------------------
# Extract "Sync" and "Warning" Icon from Shell32.dll
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
$Global:icon = [System.IconExtractor]::Extract("shell32.dll", 238, $true)


#-----------------------------------------------------
# Info Form 
#-----------------------------------------------------
function InfoForm {
    
    $MainForm.Dispose()
    $MainForm = New-Object System.Windows.Forms.Form
    
	# Set initial Coordinates and Sizes
	$X = 5
	$Y = 2
	$LabelHeight = 15
	$LabelWidth = 200
	
	#Form Parameter
	$MainForm.Text = "DynV6 Updater"
	$MainForm.Name = "MainForm"
	$MainForm.DataBindings.DefaultDataSourceUpdateMode = 0
	$MainForm.Icon = $Global:icon
    $System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Width = 300
	$System_Drawing_Size.Height = 150
	$MainForm.ClientSize = $System_Drawing_Size
	
	# Disable Resize, Minimize and Miximize of the form
	$MainForm.MaximizeBox = $false
	$MainForm.MinimizeBox = $false
	$MainForm.FormBorderStyle = 'Fixed3D'
	
	$i = 1
	# Create Text Label
	$LabelText = New-Object System.Windows.Forms.Label
	$LabelText.Text = "Host: $hostname" 
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = $X
	$System_Drawing_Point.Y = $Y+20*$i
	$LabelText.Location = $System_Drawing_Point
	$LabelText.AutoSize = $false
	$LabelText.Height = $LabelHeight
	$LabelText.Width = $LabelWidth
	$LabelText.TextAlign = "TopLeft"
	$LabelText.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
	$MainForm.Controls.Add($LabelText)
	
	$i = 2
	# Create Text Label
	$LabelText = New-Object System.Windows.Forms.Label
	$LabelText.Text = "Last Update: $Global:Date"
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = $X
	$System_Drawing_Point.Y = $Y+20*$i
	$LabelText.Location = $System_Drawing_Point
	$LabelText.AutoSize = $false
	$LabelText.Height = $LabelHeight
	$LabelText.Width = $LabelWidth
	$LabelText.TextAlign = "TopLeft"
	$LabelText.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
	$MainForm.Controls.Add($LabelText)
	
	$i = 3
	# Create Text Label
	$LabelText = New-Object System.Windows.Forms.Label
	$LabelText.Text = "IPv4: $Global:Response4"
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = $X
	$System_Drawing_Point.Y = $Y+20*$i
	$LabelText.Location = $System_Drawing_Point
	$LabelText.AutoSize = $false
	$LabelText.Height = $LabelHeight
	$LabelText.Width = $LabelWidth
	$LabelText.TextAlign = "TopLeft"
	$LabelText.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
	$MainForm.Controls.Add($LabelText)
	
	$i = 4
	# Create Text Label
	$LabelText = New-Object System.Windows.Forms.Label
	$LabelText.Text = "IPv6: $Global:Response6"
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = $X
	$System_Drawing_Point.Y = $Y+20*$i
	$LabelText.Location = $System_Drawing_Point
	$LabelText.AutoSize = $false
	$LabelText.Height = $LabelHeight
	$LabelText.Width = $LabelWidth
	$LabelText.TextAlign = "TopLeft"
	$LabelText.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
	$MainForm.Controls.Add($LabelText)
	
	# Add EXIT Button
	$ExitButton = New-Object System.Windows.Forms.Button
	$ExitButton.TabIndex = 4
	$ExitButton.Name = "ExitButton"
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Width = 50
	$System_Drawing_Size.Height = 25
	$ExitButton.Size = $System_Drawing_Size
	$ExitButton.UseVisualStyleBackColor = $True
	$ExitButton.Text = "Close"
	$System_Drawing_Point = New-Object System.Drawing.Point
	$System_Drawing_Point.X = 120
	$System_Drawing_Point.Y = 110
	$ExitButton.Location = $System_Drawing_Point
	$ExitButton.DataBindings.DefaultDataSourceUpdateMode = 0
	$MainForm.Controls.Add($ExitButton)
	
	# Add EXIT Button Click event
	$ExitButton.Add_Click({   
		#$MainForm.Close()
        $MainForm.Dispose()        
	})
	
	# Show Form
	$MainForm.ShowDialog() | Out-Null

}

# ----------------------------------------------------
# Sync Function
# ----------------------------------------------------		
function Sync {
    $Global:Response4 = Invoke-WebRequest -UseBasicParsing -URI "http://ipv4.dynv6.com/api/update?hostname=$hostname&token=$token&ipv4=auto"
    $Global:Response6 = Invoke-WebRequest -UseBasicParsing -URI "http://ipv6.dynv6.com/api/update?hostname=$hostname&token=$token&ipv6prefix=auto"
    $Global:Date = Get-Date -Format "dd/MM/yy HH:mm:ss"
    $Global:Tipicon = "Info"
    
	
    if ([string]::IsNullOrEmpty($Response4)) {
        $Global:Tipicon = "Error"
        $Global:icon = [System.IconExtractor]::Extract("shell32.dll", 237, $true)
	    $Global:Response4 = "Error! Check your credentials or Internet Connection"
    }
	
    if ([string]::IsNullOrEmpty($Response6)) {
        $Global:Tipicon = "Error"
        $Global:icon = [System.IconExtractor]::Extract("shell32.dll", 237, $true)
        $Global:Response6 = "Error! Check your credentials or IPv6 Status"
	}
}

Sync

# ----------------------------------------------------
# Add the systray menu
# ----------------------------------------------------		
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "DynV6 Updater"
$Main_Tool_Icon.Icon = $Global:icon
$Main_Tool_Icon.Visible = $true

$Main_Tool_Icon.Add_Click({
    #InfoForm
})


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

# ---------------------------------------------------------------------
# Action after clicking on Show Status
# ---------------------------------------------------------------------
$Show_Status.Add_Click({	
	InfoForm
})

# ---------------------------------------------------------------------
# Action after clicking on Sync Now
# ---------------------------------------------------------------------
$Sync_Now.Add_Click({
    Sync
    $Main_Tool_Icon.Icon = $Global:icon

    if ($MainForm.Visible) {
        InfoForm
    }
})


# ---------------------------------------------------------------------
# Action on close 
# ---------------------------------------------------------------------
# When Exit is clicked, close everything and kill the PowerShell process
$Menu_Exit.add_Click({
	$Main_Tool_Icon.Dispose()
	Stop-Process $pid
})

# ----------------------------------------------------
# Timer event to periodically sync at specified interval
# ----------------------------------------------------		
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $interval * 1000
$timer.Add_Tick({ $Sync_Now.PerformClick() })
$timer.Start()

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
