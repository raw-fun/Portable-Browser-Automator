<#
.SYNOPSIS
    Anti-Detection.ps1 - Bot Detection Prevention Strategies

.DESCRIPTION
    এই স্ক্রিপ্ট বট-ডিটেকশন প্রতিরোধের কৌশল প্রদান করে:
    - র‍্যান্ডম ডিলে জেনারেটর (Gaussian distribution)
    - টাইপিং স্পিড ভ্যারিয়েশন
    - মাউস মুভমেন্ট সিমুলেশন (ঐচ্ছিক)
    - ইউজার-এজেন্ট রোটেশন
    - Human-like behavior patterns
    
    This script provides bot detection prevention strategies:
    - Random delay generator (Gaussian distribution)
    - Typing speed variation
    - Mouse movement simulation (optional)
    - User-Agent rotation
    - Human-like behavior patterns

.NOTES
    Author: PBA Development Team
    Version: 1.0
    Last Updated: 2026-01-09
    
    Reference: BluePrint.md Lines 428-432, 720-735
    Anti-bot measures to bypass detection mechanisms
#>

#region Module Variables

# ডিফল্ট ডিলে রেঞ্জ (Default delay ranges)
$script:MinDelay = 3
$script:MaxDelay = 7
$script:DefaultMean = 5
$script:DefaultStdDev = 1.5

# টাইপিং স্পিড রেঞ্জ মিলিসেকেন্ডে (Typing speed range in milliseconds)
$script:MinTypingDelay = 50
$script:MaxTypingDelay = 200
$script:DefaultTypingSpeed = 100

# ইউজার-এজেন্ট লিস্ট (User-Agent list)
$script:UserAgents = @(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/120.0.0.0 Safari/537.36"
)

#endregion

#region Random Delay Functions

<#
.SYNOPSIS
    Get-RandomDelay - র‍্যান্ডম ডিলে জেনারেট করুন
    
.DESCRIPTION
    Gaussian distribution ব্যবহার করে মানুষের মতো র‍্যান্ডম ডিলে তৈরি করে
    Generates human-like random delays using Gaussian distribution
    
.PARAMETER Mean
    গড় ডিলে সেকেন্ডে (Mean delay in seconds)
    
.PARAMETER StdDev
    স্ট্যান্ডার্ড ডেভিয়েশন (Standard deviation)
    
.PARAMETER Min
    সর্বনিম্ন ডিলে (Minimum delay)
    
.PARAMETER Max
    সর্বোচ্চ ডিলে (Maximum delay)
    
.EXAMPLE
    Get-RandomDelay -Mean 5 -StdDev 1.5 -Min 3 -Max 7
    $delay = Get-RandomDelay
#>
function Get-RandomDelay {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [double]$Mean = $script:DefaultMean,
        
        [Parameter(Mandatory = $false)]
        [double]$StdDev = $script:DefaultStdDev,
        
        [Parameter(Mandatory = $false)]
        [double]$Min = $script:MinDelay,
        
        [Parameter(Mandatory = $false)]
        [double]$Max = $script:MaxDelay
    )
    
    try {
        # Gaussian (Normal) distribution ব্যবহার করে র‍্যান্ডম নম্বর জেনারেট করুন
        # Generate random number using Gaussian (Normal) distribution
        # Box-Muller transform method
        $u1 = [System.Random]::new().NextDouble()
        $u2 = [System.Random]::new().NextDouble()
        
        $randStdNormal = [Math]::Sqrt(-2.0 * [Math]::Log($u1)) * [Math]::Sin(2.0 * [Math]::PI * $u2)
        $randNormal = $Mean + $StdDev * $randStdNormal
        
        # Min এবং Max সীমার মধ্যে রাখুন (Clamp to Min and Max range)
        $delay = [Math]::Max($Min, [Math]::Min($Max, $randNormal))
        
        Write-LogDebug "Generated random delay: $([math]::Round($delay, 2)) seconds"
        return $delay
        
    } catch {
        Write-LogWarning "Error generating Gaussian random delay, using uniform random: $_"
        return Get-Random -Minimum $Min -Maximum $Max
    }
}

<#
.SYNOPSIS
    Start-RandomDelay - র‍্যান্ডম ডিলে এক্সিকিউট করুন
    
.DESCRIPTION
    মানুষের মতো র‍্যান্ডম ডিলে সহ Sleep করে
    Sleeps with human-like random delay
    
.PARAMETER ShowProgress
    প্রগ্রেস দেখান (Show progress during delay)
    
.EXAMPLE
    Start-RandomDelay -Mean 5 -ShowProgress
#>
function Start-RandomDelay {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [double]$Mean = $script:DefaultMean,
        
        [Parameter(Mandatory = $false)]
        [double]$StdDev = $script:DefaultStdDev,
        
        [Parameter(Mandatory = $false)]
        [double]$Min = $script:MinDelay,
        
        [Parameter(Mandatory = $false)]
        [double]$Max = $script:MaxDelay,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowProgress
    )
    
    try {
        $delay = Get-RandomDelay -Mean $Mean -StdDev $StdDev -Min $Min -Max $Max
        
        if ($ShowProgress) {
            Write-Host "Waiting $([math]::Round($delay, 1)) seconds before next action..." -ForegroundColor Cyan
        }
        
        Write-LogInfo "Applying random delay: $([math]::Round($delay, 2)) seconds"
        Start-Sleep -Seconds $delay
        
    } catch {
        Write-LogError "Error in Start-RandomDelay: $_"
    }
}

#endregion

#region Human-like Typing Functions

<#
.SYNOPSIS
    Send-HumanLikeText - মানুষের মতো টাইপিং সিমুলেট করুন
    
.DESCRIPTION
    প্রতিটি ক্যারেক্টার আলাদাভাবে টাইপ করে, ভ্যারিয়েবল স্পিডে
    Types each character separately with variable speed
    
.PARAMETER Element
    Selenium WebElement যেখানে টাইপ করতে হবে
    
.PARAMETER Text
    টাইপ করার টেক্সট (Text to type)
    
.PARAMETER MinDelay
    সর্বনিম্ন টাইপিং ডিলে মিলিসেকেন্ডে (Minimum typing delay in ms)
    
.PARAMETER MaxDelay
    সর্বোচ্চ টাইপিং ডিলে মিলিসেকেন্ডে (Maximum typing delay in ms)
    
.PARAMETER TypoChance
    টাইপো করার সম্ভাবনা 0-100 (Chance of making typo 0-100)
    
.EXAMPLE
    Send-HumanLikeText -Element $textarea -Text "Hello World" -MinDelay 50 -MaxDelay 150
#>
function Send-HumanLikeText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Element,
        
        [Parameter(Mandatory = $true)]
        [string]$Text,
        
        [Parameter(Mandatory = $false)]
        [int]$MinDelay = $script:MinTypingDelay,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxDelay = $script:MaxTypingDelay,
        
        [Parameter(Mandatory = $false)]
        [int]$TypoChance = 0  # 0-100, percentage chance of typo
    )
    
    try {
        Write-LogDebug "Typing text with human-like delays (${MinDelay}-${MaxDelay}ms per character)"
        
        $chars = $Text.ToCharArray()
        $totalChars = $chars.Length
        
        for ($i = 0; $i -lt $totalChars; $i++) {
            $char = $chars[$i]
            
            # টাইপো সিমুলেশন (ঐচ্ছিক) - Typo simulation (optional)
            if ($TypoChance -gt 0 -and (Get-Random -Minimum 0 -Maximum 100) -lt $TypoChance) {
                # র‍্যান্ডম ভুল ক্যারেক্টার টাইপ করুন এবং তারপর মুছে ফেলুন
                # Type random wrong character and then delete it
                $wrongChar = [char](Get-Random -Minimum 97 -Maximum 122)  # a-z
                $Element.SendKeys($wrongChar)
                Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 300)
                $Element.SendKeys([OpenQA.Selenium.Keys]::Backspace)
                Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 200)
            }
            
            # সঠিক ক্যারেক্টার টাইপ করুন (Type correct character)
            $Element.SendKeys($char)
            
            # স্পেস এবং বিরাম চিহ্নের পরে একটু বেশি বিরতি (Longer pause after space and punctuation)
            if ($char -eq ' ' -or $char -eq '.' -or $char -eq ',' -or $char -eq '!' -or $char -eq '?') {
                $delay = Get-Random -Minimum ($MaxDelay) -Maximum ($MaxDelay * 2)
            } else {
                $delay = Get-Random -Minimum $MinDelay -Maximum $MaxDelay
            }
            
            Start-Sleep -Milliseconds $delay
        }
        
        Write-LogInfo "Text typed successfully with human-like behavior"
        
    } catch {
        Write-LogError "Error in Send-HumanLikeText: $_"
        throw
    }
}

<#
.SYNOPSIS
    Get-TypingSpeed - টাইপিং স্পিড ক্যালকুলেট করুন
    
.DESCRIPTION
    মানুষের গড় টাইপিং স্পিডের উপর ভিত্তি করে বাস্তবসম্মত ডিলে ক্যালকুলেট করে
    Calculates realistic delay based on average human typing speed
    
.PARAMETER WPM
    Words Per Minute (ডিফল্ট: 40-60)
    
.EXAMPLE
    Get-TypingSpeed -WPM 50
#>
function Get-TypingSpeed {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$WPM = 50  # Average typing speed
    )
    
    # WPM থেকে প্রতি ক্যারেক্টার মিলিসেকেন্ড ক্যালকুলেট করুন
    # Calculate milliseconds per character from WPM
    # Assuming average word length = 5 characters
    $charactersPerMinute = $WPM * 5
    $millisecondsPerCharacter = 60000 / $charactersPerMinute
    
    return [int]$millisecondsPerCharacter
}

#endregion

#region Mouse Movement Simulation

<#
.SYNOPSIS
    Move-MouseRandomly - মাউস র‍্যান্ডমলি মুভ করুন
    
.DESCRIPTION
    মাউসকে এলোমেলোভাবে সরিয়ে মানুষের আচরণ সিমুলেট করে
    Moves mouse randomly to simulate human behavior
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট
    
.PARAMETER Movements
    কতবার মুভ করবে (Number of movements)
    
.EXAMPLE
    Move-MouseRandomly -Driver $driver -Movements 3
    
.NOTES
    Requires Selenium Actions class
    TODO: Implement Bezier curve for natural mouse movement
#>
function Move-MouseRandomly {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$Movements = 2
    )
    
    try {
        Write-LogDebug "Simulating random mouse movements"
        
        # Actions অবজেক্ট তৈরি করুন (Create Actions object)
        # Note: Requires OpenQA.Selenium.Interactions namespace
        
        for ($i = 0; $i -lt $Movements; $i++) {
            # র‍্যান্ডম offset জেনারেট করুন (Generate random offset)
            $xOffset = Get-Random -Minimum -100 -Maximum 100
            $yOffset = Get-Random -Minimum -100 -Maximum 100
            
            # JavaScript দিয়ে মাউস ইভেন্ট সিমুলেট করুন (Simulate mouse event with JavaScript)
            $script = @"
                var event = new MouseEvent('mousemove', {
                    'view': window,
                    'bubbles': true,
                    'cancelable': true,
                    'clientX': $xOffset,
                    'clientY': $yOffset
                });
                document.dispatchEvent(event);
"@
            $Driver.ExecuteScript($script)
            
            Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
        }
        
        Write-LogDebug "Mouse movements completed"
        
    } catch {
        Write-LogWarning "Could not simulate mouse movement: $_"
    }
}

#endregion

#region User-Agent Management

<#
.SYNOPSIS
    Get-RandomUserAgent - র‍্যান্ডম ইউজার-এজেন্ট স্ট্রিং পান
    
.DESCRIPTION
    একটি তালিকা থেকে র‍্যান্ডম ইউজার-এজেন্ট নির্বাচন করে
    Selects a random user-agent from a list
    
.EXAMPLE
    $userAgent = Get-RandomUserAgent
#>
function Get-RandomUserAgent {
    [CmdletBinding()]
    param()
    
    $randomIndex = Get-Random -Minimum 0 -Maximum $script:UserAgents.Count
    $userAgent = $script:UserAgents[$randomIndex]
    
    Write-LogDebug "Selected User-Agent: $userAgent"
    return $userAgent
}

<#
.SYNOPSIS
    Set-BrowserUserAgent - ব্রাউজারে ইউজার-এজেন্ট সেট করুন
    
.DESCRIPTION
    ChromeOptions-এ ইউজার-এজেন্ট সেট করে (ব্রাউজার লঞ্চের আগে)
    Sets user-agent in ChromeOptions (before browser launch)
    
.PARAMETER ChromeOptions
    ChromeOptions অবজেক্ট
    
.PARAMETER UserAgent
    ইউজার-এজেন্ট স্ট্রিং (Optional, random if not provided)
    
.EXAMPLE
    Set-BrowserUserAgent -ChromeOptions $options
#>
function Set-BrowserUserAgent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ChromeOptions,
        
        [Parameter(Mandatory = $false)]
        [string]$UserAgent
    )
    
    try {
        if ([string]::IsNullOrEmpty($UserAgent)) {
            $UserAgent = Get-RandomUserAgent
        }
        
        $ChromeOptions.AddArgument("user-agent=$UserAgent")
        Write-LogInfo "User-Agent configured: $UserAgent"
        
    } catch {
        Write-LogError "Failed to set User-Agent: $_"
    }
}

#endregion

#region Browser Fingerprint Obfuscation

<#
.SYNOPSIS
    Hide-AutomationFlags - অটোমেশন ফ্ল্যাগ লুকান
    
.DESCRIPTION
    ব্রাউজারে অটোমেশন ডিটেকশন ফিচার ডিসেবল করে
    Disables automation detection features in browser
    
.PARAMETER ChromeOptions
    ChromeOptions অবজেক্ট
    
.EXAMPLE
    Hide-AutomationFlags -ChromeOptions $options
#>
function Hide-AutomationFlags {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ChromeOptions
    )
    
    try {
        # অটোমেশন ফ্ল্যাগ ডিসেবল করুন (Disable automation flags)
        $ChromeOptions.AddArgument("--disable-blink-features=AutomationControlled")
        $ChromeOptions.AddExcludedArgument("enable-automation")
        $ChromeOptions.AddAdditionalOption("useAutomationExtension", $false)
        
        Write-LogInfo "Automation detection flags hidden"
        
    } catch {
        Write-LogError "Failed to hide automation flags: $_"
    }
}

<#
.SYNOPSIS
    Remove-WebDriverProperty - WebDriver প্রপার্টি মুছে ফেলুন
    
.DESCRIPTION
    JavaScript দিয়ে navigator.webdriver প্রপার্টি মুছে ফেলে
    Removes navigator.webdriver property using JavaScript
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট
    
.EXAMPLE
    Remove-WebDriverProperty -Driver $driver
#>
function Remove-WebDriverProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver
    )
    
    try {
        # navigator.webdriver প্রপার্টি অপসারণ করুন (Remove navigator.webdriver property)
        $script = @"
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });
"@
        $Driver.ExecuteScript($script)
        
        Write-LogDebug "WebDriver property removed from navigator"
        
    } catch {
        Write-LogWarning "Could not remove WebDriver property: $_"
    }
}

#endregion

#region Behavioral Patterns

<#
.SYNOPSIS
    Simulate-HumanBehavior - মানুষের আচরণ সিমুলেট করুন
    
.DESCRIPTION
    বিভিন্ন মানুষের মতো আচরণ একসাথে সিমুলেট করে:
    - র‍্যান্ডম ডিলে
    - মাউস মুভমেন্ট
    - পেজ স্ক্রলিং
    
    Simulates various human-like behaviors together:
    - Random delays
    - Mouse movements
    - Page scrolling
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট
    
.PARAMETER Intensity
    আচরণের তীব্রতা (Behavior intensity: Low, Medium, High)
    
.EXAMPLE
    Simulate-HumanBehavior -Driver $driver -Intensity "Medium"
#>
function Simulate-HumanBehavior {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Low", "Medium", "High")]
        [string]$Intensity = "Medium"
    )
    
    try {
        Write-LogDebug "Simulating human behavior (Intensity: $Intensity)"
        
        # Intensity অনুযায়ী প্যারামিটার সেট করুন (Set parameters based on intensity)
        $params = switch ($Intensity) {
            "Low"    { @{ Movements = 1; ScrollChance = 20; DelayMean = 3 } }
            "Medium" { @{ Movements = 2; ScrollChance = 50; DelayMean = 5 } }
            "High"   { @{ Movements = 3; ScrollChance = 80; DelayMean = 7 } }
        }
        
        # র‍্যান্ডম মাউস মুভমেন্ট (Random mouse movements)
        Move-MouseRandomly -Driver $Driver -Movements $params.Movements
        
        # কখনও কখনও পেজ স্ক্রল করুন (Occasionally scroll page)
        if ((Get-Random -Minimum 0 -Maximum 100) -lt $params.ScrollChance) {
            $scrollAmount = Get-Random -Minimum 100 -Maximum 500
            $Driver.ExecuteScript("window.scrollBy(0, $scrollAmount);")
            Write-LogDebug "Scrolled page by $scrollAmount pixels"
            Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 1500)
        }
        
        # র‍্যান্ডম ডিলে (Random delay)
        Start-RandomDelay -Mean $params.DelayMean
        
        Write-LogInfo "Human behavior simulation completed"
        
    } catch {
        Write-LogError "Error in Simulate-HumanBehavior: $_"
    }
}

#endregion

#region Export Functions

# এই ফাংশনগুলো export করুন (Export these functions)
Export-ModuleMember -Function @(
    'Get-RandomDelay',
    'Start-RandomDelay',
    'Send-HumanLikeText',
    'Get-TypingSpeed',
    'Move-MouseRandomly',
    'Get-RandomUserAgent',
    'Set-BrowserUserAgent',
    'Hide-AutomationFlags',
    'Remove-WebDriverProperty',
    'Simulate-HumanBehavior'
)

#endregion

<#
.NOTES
    Future Improvements / ভবিষ্যৎ উন্নতি:
    ----------------------------------------
    TODO: Implement Bezier curve for natural mouse movements
    TODO: Add realistic scrolling patterns (not just straight down)
    TODO: Implement canvas fingerprint randomization
    TODO: Add WebGL fingerprint obfuscation
    TODO: Implement timezone and locale spoofing
    TODO: Add browser plugin detection spoofing
    TODO: Implement battery status API spoofing
    TODO: Add touch event simulation for mobile emulation
    TODO: Implement realistic reading time simulation (based on content length)
    TODO: Add tab switching and focus simulation
    TODO: Implement copy-paste behavior simulation
    TODO: Add realistic form filling patterns (with corrections)
    TODO: Implement session timing variation (not always same duration)
    TODO: Add IP rotation support (requires proxy integration)
#>
