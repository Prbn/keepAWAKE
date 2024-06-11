$intHours = Read-Host "Enter the time in hours:"
# $interval = 15000 # Every 30 Second
# $interval = 30000 # Every 30 Second
# $interval = 60000 # Every 1 Minute
# $interval = 300000 # Every 5 Minute
# $interval = 600000 # Every 10 Minute

$interval = 60000 # Every 1 Minute

$WshShell = New-Object -ComObject WScript.Shell
$random = New-Object System.Random

function tap-numlock {
    $WshShell.SendKeys("{NUMLOCK}")
    Start-Sleep -Milliseconds 100  # Sleep for 1 second (1000 milliseconds)
    $WshShell.SendKeys("{NUMLOCK}")
    Start-Sleep -Milliseconds 100  # Sleep for 1 second (1000 milliseconds)
}

# Function to scroll up and down a specified number of times
function toggle-AltTab($n) {
    # alt-tab n times
    for ($i = 0; $i -le $n; $i++) {
        # alt-tab
        $WshShell.SendKeys("%{TAB}")  # % represents the Alt key in SendKeys method
        Start-Sleep -Milliseconds $random.Next(50, 301)  # Short pause
        $WshShell.SendKeys("%{TAB}")  # % represents the Alt key in SendKeys method
        Start-Sleep -Milliseconds $random.Next(10, 201)  # Short pause
    }
}


# Function to scroll up and down a specified number of times
function movement-UpDown($n) {
    # Scroll up
    for ($i = 1; $i -le $n; $i++) {
        # Scroll up
        $WshShell.SendKeys("{UP}")
        Start-Sleep -Milliseconds $random.Next(10, 201)  # Short pause
    }
    # Scroll down
    for ($i = 1; $i -le $n; $i++) {
        $WshShell.SendKeys("{DOWN}")
        Start-Sleep -Milliseconds $random.Next(10, 201)  # Short pause
    }
}

# Load System.Windows.Forms and System.Drawing assemblies for mouse control
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Add user32.dll for mouse click control
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class MouseSimulator {
        [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
        public const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
        public const int MOUSEEVENTF_RIGHTUP = 0x0010;
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int X, int Y);
        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out POINT lpPoint);
        public struct POINT {
            public int X;
            public int Y;
        }
    }
"@


function Get-CursorPosition {
    $point = New-Object MouseSimulator+POINT
    [MouseSimulator]::GetCursorPos([ref]$point) | Out-Null
    return New-Object System.Drawing.Point($point.X, $point.Y)
}

# Function to press the Esc key
function Press-Esc {
    $WshShell.SendKeys("{ESC}")
}

# Function to perform a right-click at the current mouse position
function Right-Click {
    [MouseSimulator]::mouse_event([MouseSimulator]::MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 100  # Sleep for 1 second (1000 milliseconds)
    [MouseSimulator]::mouse_event([MouseSimulator]::MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 100  # Sleep for 1 second (1000 milliseconds)
}

function Set-CursorPosition($point) {
    [MouseSimulator]::SetCursorPos($point.X, $point.Y)
    Right-Click
    Press-Esc
}

function LinearSmoothMove($newPosition, [TimeSpan]$duration) {
    $start = Get-CursorPosition

    # Find the vector between start and newPosition
    $deltaX = $newPosition.X - $start.X
    $deltaY = $newPosition.Y - $start.Y

    # Start a stopwatch
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $timeFraction = 0.0

    do {
        $timeFraction = [double]$stopwatch.Elapsed.Ticks / $duration.Ticks
        if ($timeFraction -gt 1.0) {
        $timeFraction = 1.0
        }

        $curPoint = [System.Drawing.PointF]::new(
            $start.X + $timeFraction * $deltaX,
            $start.Y + $timeFraction * $deltaY
        )
        Set-CursorPosition([System.Drawing.Point]::Round($curPoint))
        Start-Sleep -Milliseconds 2
    } while ($timeFraction -lt 1.0)
}


function Move-MouseRandom {
    $screenWidth = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
    $screenHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height

    $x_d = $random.Next(0, $screenWidth)
    $y_d = $random.Next(0, $screenHeight)

    Write-Host $x_d", "$y_d

    $newPosition = New-Object System.Drawing.Point $x_d, $y_d 
    $duration = [TimeSpan]::FromSeconds($random.Next(1, 4))
    LinearSmoothMove $newPosition $duration
    Right-Click
    Press-Esc
}

# Main Code
if ($intHours -as [double]) {
    $intTime = [Int64]([Int64]([Int64]($intHours) * 60 * 60 * 1000)/[Int64]($interval))
    $random = New-Object System.Random
    
    for ($i = 1; $i -le $intTime; $i++) {
        Write-Host $i"/"$intTime
        
        # NUM Lock
        tap-numlock
        
	# Alt-Tab
	toggle-AltTab(2)
	
        # UP DOWN Movement
        movement-UpDown($random.Next(3, 10))
        
	# move Mouse
	Move-MouseRandom

        Start-Sleep -Milliseconds $interval  # Sleep for interval
    }
} else {
    Write-Host "Invalid input. Please enter a numeric value for hours."
}