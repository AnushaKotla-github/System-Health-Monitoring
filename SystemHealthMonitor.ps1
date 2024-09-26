# Define thresholds for testing
$CPU_THRESHOLD = 80        # CPU usage threshold in percentage
$MEMORY_THRESHOLD = 80     # Memory usage threshold in percentage
$DISK_THRESHOLD = 90       # Disk space usage threshold in percentage
$PROCESS_THRESHOLD = 200   # Running processes threshold

# Define log file path
$logPath = "C:\Users\91990\Documents\SystemHealthLog.txt"  # Change the path as needed

# Function to write log messages
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logPath
}

# Function to check CPU usage
function Check-CPU {
    Write-Log "Checking CPU..."
    try {
        $cpuUsage = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
        if ($cpuUsage -gt $CPU_THRESHOLD) {
            Write-Log "CPU usage is high: $cpuUsage%"
        }
    } catch {
        Write-Log "Error checking CPU usage: $_"
    }
}

# Function to check memory usage
function Check-Memory {
    Write-Log "Checking Memory..."
    try {
        $memory = Get-WmiObject Win32_OperatingSystem
        $totalMemory = $memory.TotalVisibleMemorySize
        $freeMemory = $memory.FreePhysicalMemory
        $usedMemory = $totalMemory - $freeMemory
        $memoryUsage = [math]::round(($usedMemory / $totalMemory) * 100, 2)
        if ($memoryUsage -gt $MEMORY_THRESHOLD) {
            Write-Log "Memory usage is high: $memoryUsage%"
        }
    } catch {
        Write-Log "Error checking memory usage: $_"
    }
}

# Function to check disk space usage
function Check-Disk {
    Write-Log "Checking Disk..."
    try {
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($d in $disk) {
            $diskUsage = [math]::round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 2)
            if ($diskUsage -gt $DISK_THRESHOLD) {
                Write-Log "Disk space usage is high on $($d.DeviceID): $diskUsage%"
            }
        }
    } catch {
        Write-Log "Error checking disk usage: $_"
    }
}

# Function to check running processes
function Check-Processes {
    Write-Log "Checking Processes..."
    try {
        $runningProcesses = Get-Process | Measure-Object
        if ($runningProcesses.Count -gt $PROCESS_THRESHOLD) {
            Write-Log "Number of running processes is high: $($runningProcesses.Count)"
        }
    } catch {
        Write-Log "Error checking running processes: $_"
    }
}

# Main monitoring function
function Monitor-System {
    Write-Log "Monitoring run at $(Get-Date)"
    Check-CPU
    Check-Memory
    Check-Disk
    Check-Processes
    Write-Log "Monitoring completed."
}

# Execute the monitoring function
Monitor-System


