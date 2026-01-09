<#
.SYNOPSIS
    Logger.ps1 - Centralized Logging System for PBA (Portable Browser Automator)

.DESCRIPTION
    এই স্ক্রিপ্ট একটি সম্পূর্ণ লগিং সিস্টেম প্রদান করে যা:
    - টাইমস্ট্যাম্প-ভিত্তিক লগ এন্ট্রি তৈরি করে
    - বিভিন্ন লগ লেভেল সাপোর্ট করে (INFO, WARN, ERROR, DEBUG)
    - দৈনিক লগ ফাইল রোটেশন করে
    - কনসোল এবং ফাইল উভয়ে লগ করে
    
    This script provides a complete logging system that:
    - Creates timestamp-based log entries
    - Supports different log levels (INFO, WARN, ERROR, DEBUG)
    - Performs daily log file rotation
    - Logs to both console and file

.NOTES
    Author: PBA Development Team
    Version: 1.0
    Last Updated: 2026-01-09
    
    Reference: BluePrint.md Lines 454-464
#>

#region Module Variables

# লগ ফাইলের ডিফল্ট পাথ (Default log file path)
$script:LogDirectory = Join-Path $PSScriptRoot "..\..\Workspace\Logs"
$script:CurrentLogFile = $null
$script:LogLevel = "INFO"  # Minimum log level: DEBUG, INFO, WARN, ERROR

# লগ লেভেল প্রায়োরিটি ম্যাপিং (Log level priority mapping)
$script:LogLevelPriority = @{
    "DEBUG" = 0
    "INFO"  = 1
    "WARN"  = 2
    "ERROR" = 3
}

#endregion

#region Initialization Functions

<#
.SYNOPSIS
    Initialize-Logger - লগিং সিস্টেম ইনিশিয়ালাইজ করে
    
.DESCRIPTION
    লগ ডিরেক্টরি তৈরি করে এবং দৈনিক লগ ফাইল সেট করে
    Creates log directory and sets up daily log file
    
.PARAMETER LogPath
    কাস্টম লগ ডিরেক্টরি পাথ (Optional custom log directory path)
    
.PARAMETER MinLogLevel
    মিনিমাম লগ লেভেল (Minimum log level to record)
    
.EXAMPLE
    Initialize-Logger
    Initialize-Logger -LogPath "C:\MyLogs" -MinLogLevel "WARN"
#>
function Initialize-Logger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$LogPath = $script:LogDirectory,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$MinLogLevel = "INFO"
    )
    
    try {
        # লগ ডিরেক্টরি তৈরি করুন যদি না থাকে (Create log directory if it doesn't exist)
        if (-not (Test-Path -Path $LogPath)) {
            New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
            Write-Host "[Logger] Created log directory: $LogPath" -ForegroundColor Green
        }
        
        $script:LogDirectory = $LogPath
        $script:LogLevel = $MinLogLevel
        
        # আজকের তারিখের জন্য লগ ফাইল তৈরি করুন (Create log file for today's date)
        $dateStamp = Get-Date -Format "yyyy-MM-dd"
        $script:CurrentLogFile = Join-Path $LogPath "automation-$dateStamp.log"
        
        # লগ ফাইলে হেডার লিখুন (Write header to log file)
        if (-not (Test-Path -Path $script:CurrentLogFile)) {
            $header = @"
================================================================================
PBA (Portable Browser Automator) - Automation Log
Session Started: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Log Level: $MinLogLevel
================================================================================

"@
            Add-Content -Path $script:CurrentLogFile -Value $header -Encoding UTF8
        }
        
        Write-Log -Message "Logger initialized successfully. Log file: $script:CurrentLogFile" -Level "INFO"
        return $true
        
    } catch {
        Write-Host "[ERROR] Failed to initialize logger: $_" -ForegroundColor Red
        return $false
    }
}

#endregion

#region Core Logging Functions

<#
.SYNOPSIS
    Write-Log - প্রধান লগিং ফাংশন
    
.DESCRIPTION
    লগ মেসেজ ফাইল এবং কনসোলে লেখে
    Writes log messages to file and console
    
.PARAMETER Message
    লগ করার মেসেজ (Message to log)
    
.PARAMETER Level
    লগ লেভেল (Log level: DEBUG, INFO, WARN, ERROR)
    
.PARAMETER NoConsole
    কনসোলে প্রিন্ট করবেন না (Don't print to console)
    
.EXAMPLE
    Write-Log -Message "Automation started" -Level "INFO"
    Write-Log -Message "Element not found" -Level "ERROR"
#>
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO",
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole
    )
    
    try {
        # লগ ডিরেক্টরি চেক করুন, প্রয়োজনে ইনিশিয়ালাইজ করুন
        # Check log directory, initialize if needed
        if ($null -eq $script:CurrentLogFile) {
            Initialize-Logger | Out-Null
        }
        
        # লগ লেভেল ফিল্টারিং (Log level filtering)
        if ($script:LogLevelPriority[$Level] -lt $script:LogLevelPriority[$script:LogLevel]) {
            return  # Skip logging if below minimum level
        }
        
        # টাইমস্ট্যাম্প ও ফরম্যাট করা মেসেজ (Timestamp and formatted message)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # ফাইলে লগ লিখুন (Write to log file)
        Add-Content -Path $script:CurrentLogFile -Value $logEntry -Encoding UTF8
        
        # কনসোলে প্রিন্ট করুন (Print to console)
        if (-not $NoConsole) {
            $color = switch ($Level) {
                "DEBUG" { "Gray" }
                "INFO"  { "White" }
                "WARN"  { "Yellow" }
                "ERROR" { "Red" }
                default { "White" }
            }
            Write-Host $logEntry -ForegroundColor $color
        }
        
    } catch {
        Write-Host "[ERROR] Failed to write log: $_" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
    Write-LogInfo - INFO লেভেল লগ (Shortcut for INFO level logging)
#>
function Write-LogInfo {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "INFO"
}

<#
.SYNOPSIS
    Write-LogWarning - WARN লেভেল লগ (Shortcut for WARN level logging)
#>
function Write-LogWarning {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "WARN"
}

<#
.SYNOPSIS
    Write-LogError - ERROR লেভেল লগ (Shortcut for ERROR level logging)
#>
function Write-LogError {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "ERROR"
}

<#
.SYNOPSIS
    Write-LogDebug - DEBUG লেভেল লগ (Shortcut for DEBUG level logging)
#>
function Write-LogDebug {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "DEBUG"
}

#endregion

#region Performance Metrics Functions

<#
.SYNOPSIS
    Measure-ActionTime - একশন এক্সিকিউশন টাইম মাপুন
    
.DESCRIPTION
    কোনো স্ক্রিপ্ট ব্লক এক্সিকিউট করে এবং সময় লগ করে
    Executes a script block and logs the execution time
    
.PARAMETER ActionName
    একশনের নাম (Name of the action)
    
.PARAMETER ScriptBlock
    এক্সিকিউট করার স্ক্রিপ্ট ব্লক (Script block to execute)
    
.EXAMPLE
    Measure-ActionTime -ActionName "Page Load" -ScriptBlock { Start-Sleep -Seconds 2 }
#>
function Measure-ActionTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActionName,
        
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock
    )
    
    try {
        Write-LogDebug "Starting action: $ActionName"
        $startTime = Get-Date
        
        # স্ক্রিপ্ট ব্লক এক্সিকিউট করুন (Execute script block)
        $result = & $ScriptBlock
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-LogInfo "Action '$ActionName' completed in $([math]::Round($duration, 2)) seconds"
        
        return $result
        
    } catch {
        Write-LogError "Action '$ActionName' failed: $_"
        throw
    }
}

#endregion

#region Log Maintenance Functions

<#
.SYNOPSIS
    Clear-OldLogs - পুরাতন লগ ফাইল মুছে ফেলুন
    
.DESCRIPTION
    নির্দিষ্ট দিনের চেয়ে পুরাতন লগ ফাইল ডিলিট করে
    Deletes log files older than specified days
    
.PARAMETER DaysToKeep
    কত দিনের লগ রাখবেন (Number of days to keep logs)
    
.EXAMPLE
    Clear-OldLogs -DaysToKeep 7
#>
function Clear-OldLogs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$DaysToKeep = 30
    )
    
    try {
        $cutoffDate = (Get-Date).AddDays(-$DaysToKeep)
        $oldLogs = Get-ChildItem -Path $script:LogDirectory -Filter "*.log" | 
                   Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        if ($oldLogs) {
            $count = $oldLogs.Count
            $oldLogs | Remove-Item -Force
            Write-LogInfo "Cleaned up $count old log file(s) older than $DaysToKeep days"
        } else {
            Write-LogDebug "No old logs to clean up"
        }
        
    } catch {
        Write-LogError "Failed to clean old logs: $_"
    }
}

<#
.SYNOPSIS
    Get-LogStats - লগ পরিসংখ্যান প্রদর্শন করুন
    
.DESCRIPTION
    বর্তমান সেশনের লগ পরিসংখ্যান দেখায়
    Shows log statistics for current session
    
.EXAMPLE
    Get-LogStats
#>
function Get-LogStats {
    [CmdletBinding()]
    param()
    
    try {
        if ($null -eq $script:CurrentLogFile -or -not (Test-Path $script:CurrentLogFile)) {
            Write-LogWarning "No active log file found"
            return
        }
        
        $logContent = Get-Content -Path $script:CurrentLogFile
        $infoCount = ($logContent | Select-String -Pattern "\[INFO\]").Count
        $warnCount = ($logContent | Select-String -Pattern "\[WARN\]").Count
        $errorCount = ($logContent | Select-String -Pattern "\[ERROR\]").Count
        $debugCount = ($logContent | Select-String -Pattern "\[DEBUG\]").Count
        
        $stats = @"

================================================================================
Log Statistics - $(Split-Path $script:CurrentLogFile -Leaf)
================================================================================
Total Entries: $($logContent.Count)
INFO:  $infoCount
WARN:  $warnCount
ERROR: $errorCount
DEBUG: $debugCount
================================================================================

"@
        Write-Host $stats -ForegroundColor Cyan
        
    } catch {
        Write-LogError "Failed to get log stats: $_"
    }
}

#endregion

#region Export Functions

# এই ফাংশনগুলো export করুন যাতে অন্য স্ক্রিপ্ট ব্যবহার করতে পারে
# Export these functions for use in other scripts
Export-ModuleMember -Function @(
    'Initialize-Logger',
    'Write-Log',
    'Write-LogInfo',
    'Write-LogWarning',
    'Write-LogError',
    'Write-LogDebug',
    'Measure-ActionTime',
    'Clear-OldLogs',
    'Get-LogStats'
)

#endregion

<#
.NOTES
    Future Improvements / ভবিষ্যৎ উন্নতি:
    ----------------------------------------
    TODO: Add log file size rotation (rotate when file exceeds certain size)
    TODO: Add structured logging (JSON format option)
    TODO: Add remote logging capability (send logs to remote server)
    TODO: Add log compression for archived logs
    TODO: Add email notification for ERROR level logs
    TODO: Add performance dashboard generation from logs
    TODO: Add log filtering and search functionality
    TODO: Add color-coded HTML log viewer
#>
