<#
.SYNOPSIS
    Smart-Wait.ps1 - Intelligent Waiting Mechanisms for Browser Automation

.DESCRIPTION
    এই স্ক্রিপ্ট ডায়নামিক ওয়েট ফাংশন প্রদান করে যা:
    - DOM মিউটেশন অবজার্ভার ব্যবহার করে
    - লোডিং ইন্ডিকেটর ডিটেক্ট করে
    - টেক্সট স্ট্যাবিলিটি মনিটর করে
    - নেটওয়ার্ক আইডল ডিটেকশন করে
    
    This script provides dynamic wait functions that:
    - Uses DOM mutation observers
    - Detects loading indicators
    - Monitors text stability
    - Detects network idle state

.NOTES
    Author: PBA Development Team
    Version: 1.0
    Last Updated: 2026-01-09
    
    Reference: BluePrint.md Lines 402-404, 433-436, 674-717
    Requires: Selenium WebDriver
#>

#region Module Variables

# ডিফল্ট টাইমআউট সেটিংস (Default timeout settings)
$script:DefaultTimeout = 300  # seconds
$script:DefaultCheckInterval = 2  # seconds
$script:StabilityThreshold = 3  # consecutive stable checks needed

#endregion

#region Element Wait Functions

<#
.SYNOPSIS
    Wait-ForElement - এলিমেন্ট প্রদর্শিত হওয়ার জন্য অপেক্ষা করুন
    
.DESCRIPTION
    নির্দিষ্ট সিলেক্টরের এলিমেন্ট DOM-এ দৃশ্যমান হওয়া পর্যন্ত অপেক্ষা করে
    Waits until an element with the specified selector is visible in the DOM
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট (Selenium WebDriver object)
    
.PARAMETER Selector
    CSS সিলেক্টর (CSS selector)
    
.PARAMETER Timeout
    সর্বোচ্চ অপেক্ষার সময় সেকেন্ডে (Maximum wait time in seconds)
    
.PARAMETER By
    সিলেক্টর টাইপ (Selector type: CssSelector, XPath, Id, etc.)
    
.EXAMPLE
    Wait-ForElement -Driver $driver -Selector "textarea" -Timeout 30
    Wait-ForElement -Driver $driver -Selector "//textarea[@placeholder]" -By "XPath"
#>
function Wait-ForElement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $true)]
        [string]$Selector,
        
        [Parameter(Mandatory = $false)]
        [int]$Timeout = 30,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("CssSelector", "XPath", "Id", "ClassName", "Name", "TagName")]
        [string]$By = "CssSelector"
    )
    
    try {
        Write-LogDebug "Waiting for element: $Selector (By: $By, Timeout: ${Timeout}s)"
        
        $startTime = Get-Date
        $found = $false
        
        while (((Get-Date) - $startTime).TotalSeconds -lt $Timeout) {
            try {
                # এলিমেন্ট খুঁজে বের করার চেষ্টা করুন (Try to find the element)
                $element = switch ($By) {
                    "CssSelector" { $Driver.FindElement([OpenQA.Selenium.By]::CssSelector($Selector)) }
                    "XPath"       { $Driver.FindElement([OpenQA.Selenium.By]::XPath($Selector)) }
                    "Id"          { $Driver.FindElement([OpenQA.Selenium.By]::Id($Selector)) }
                    "ClassName"   { $Driver.FindElement([OpenQA.Selenium.By]::ClassName($Selector)) }
                    "Name"        { $Driver.FindElement([OpenQA.Selenium.By]::Name($Selector)) }
                    "TagName"     { $Driver.FindElement([OpenQA.Selenium.By]::TagName($Selector)) }
                }
                
                # এলিমেন্ট দৃশ্যমান এবং ইন্টারঅ্যাক্টযোগ্য কিনা চেক করুন
                # Check if element is visible and interactable
                if ($element.Displayed -and $element.Enabled) {
                    Write-LogInfo "Element found and ready: $Selector"
                    $found = $true
                    return $element
                }
                
            } catch {
                # এলিমেন্ট এখনও পাওয়া যায়নি, অপেক্ষা চালিয়ে যান
                # Element not found yet, continue waiting
            }
            
            Start-Sleep -Seconds 1
        }
        
        if (-not $found) {
            Write-LogWarning "Element not found within timeout: $Selector"
            return $null
        }
        
    } catch {
        Write-LogError "Error waiting for element: $_"
        return $null
    }
}

#endregion

#region AI Response Wait Functions

<#
.SYNOPSIS
    Wait-ForAIResponse - AI রেসপন্স সম্পূর্ণ হওয়ার জন্য অপেক্ষা করুন
    
.DESCRIPTION
    AI প্ল্যাটফর্মের রেসপন্স সম্পূর্ণ হওয়া পর্যন্ত অপেক্ষা করে
    তিনটি মেথড ব্যবহার করে: লোডিং ইন্ডিকেটর, টেক্সট স্ট্যাবিলিটি, এবং DOM মিউটেশন
    
    Waits for AI platform response to complete
    Uses three methods: loading indicator, text stability, and DOM mutation
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট (Selenium WebDriver object)
    
.PARAMETER MaxSeconds
    সর্বোচ্চ অপেক্ষার সময় (Maximum wait time in seconds)
    
.PARAMETER CheckInterval
    চেক করার ইন্টারভাল (Check interval in seconds)
    
.PARAMETER Method
    ডিটেকশন মেথড (Detection method: LoadingIndicator, TextStability, MutationObserver, Auto)
    
.EXAMPLE
    Wait-ForAIResponse -Driver $driver -MaxSeconds 300
    Wait-ForAIResponse -Driver $driver -Method "TextStability"
#>
function Wait-ForAIResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxSeconds = $script:DefaultTimeout,
        
        [Parameter(Mandatory = $false)]
        [int]$CheckInterval = $script:DefaultCheckInterval,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("LoadingIndicator", "TextStability", "MutationObserver", "Auto")]
        [string]$Method = "Auto"
    )
    
    try {
        Write-LogInfo "Waiting for AI response (Method: $Method, Max: ${MaxSeconds}s)"
        $startTime = Get-Date
        
        switch ($Method) {
            "LoadingIndicator" {
                return Wait-ForLoadingComplete -Driver $Driver -MaxSeconds $MaxSeconds -CheckInterval $CheckInterval
            }
            "TextStability" {
                return Wait-ForTextStability -Driver $Driver -MaxSeconds $MaxSeconds -CheckInterval $CheckInterval
            }
            "MutationObserver" {
                return Wait-UsingMutationObserver -Driver $Driver -MaxSeconds $MaxSeconds
            }
            "Auto" {
                # Auto mode: প্রথমে লোডিং ইন্ডিকেটর, তারপর টেক্সট স্ট্যাবিলিটি
                # Auto mode: First try loading indicator, then text stability
                $result1 = Wait-ForLoadingComplete -Driver $Driver -MaxSeconds 30 -CheckInterval 1
                if ($result1) {
                    $result2 = Wait-ForTextStability -Driver $Driver -MaxSeconds 60 -CheckInterval 2
                    return $result2
                }
                return $false
            }
        }
        
    } catch {
        Write-LogError "Error waiting for AI response: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Wait-ForLoadingComplete - লোডিং ইন্ডিকেটর অদৃশ্য হওয়ার জন্য অপেক্ষা করুন
    
.DESCRIPTION
    পেজে লোডিং ইন্ডিকেটর অদৃশ্য হওয়া পর্যন্ত অপেক্ষা করে
    Waits until loading indicators disappear from the page
    
.EXAMPLE
    Wait-ForLoadingComplete -Driver $driver
#>
function Wait-ForLoadingComplete {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxSeconds = 60,
        
        [Parameter(Mandatory = $false)]
        [int]$CheckInterval = 2
    )
    
    try {
        Write-LogDebug "Checking for loading indicators..."
        
        # সাধারণ লোডিং সিলেক্টর (Common loading selectors)
        $loadingSelectors = @(
            ".loading",
            ".spinner",
            "[class*='loading']",
            "[class*='spinner']",
            "[aria-busy='true']",
            ".animate-spin"
        )
        
        $startTime = Get-Date
        $loadingFound = $false
        
        while (((Get-Date) - $startTime).TotalSeconds -lt $MaxSeconds) {
            $hasLoading = $false
            
            foreach ($selector in $loadingSelectors) {
                try {
                    $elements = $Driver.FindElements([OpenQA.Selenium.By]::CssSelector($selector))
                    if ($elements.Count -gt 0) {
                        $hasLoading = $true
                        $loadingFound = $true
                        break
                    }
                } catch {
                    # সিলেক্টর পাওয়া যায়নি, চালিয়ে যান (Selector not found, continue)
                }
            }
            
            if (-not $hasLoading) {
                if ($loadingFound) {
                    Write-LogInfo "Loading indicators disappeared"
                    return $true
                } else {
                    Write-LogDebug "No loading indicators found"
                    return $true
                }
            }
            
            Start-Sleep -Seconds $CheckInterval
        }
        
        Write-LogWarning "Loading did not complete within timeout"
        return $false
        
    } catch {
        Write-LogError "Error in Wait-ForLoadingComplete: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Wait-ForTextStability - টেক্সট স্ট্যাবিলিটি চেক করে অপেক্ষা করুন
    
.DESCRIPTION
    রেসপন্স কন্টেইনারের টেক্সট স্থিতিশীল হওয়া পর্যন্ত অপেক্ষা করে
    Waits until the response container's text becomes stable
    
.PARAMETER ResponseSelector
    রেসপন্স কন্টেইনারের সিলেক্টর (Response container selector)
    
.EXAMPLE
    Wait-ForTextStability -Driver $driver -ResponseSelector ".response-container"
#>
function Wait-ForTextStability {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxSeconds = 120,
        
        [Parameter(Mandatory = $false)]
        [int]$CheckInterval = 2,
        
        [Parameter(Mandatory = $false)]
        [string]$ResponseSelector = ".markdown, .response, [class*='message'], [class*='response']"
    )
    
    try {
        Write-LogDebug "Monitoring text stability..."
        
        $startTime = Get-Date
        $previousText = ""
        $stableCount = 0
        $requiredStableChecks = $script:StabilityThreshold
        
        while (((Get-Date) - $startTime).TotalSeconds -lt $MaxSeconds) {
            try {
                # রেসপন্স এলিমেন্ট খুঁজুন (Find response element)
                $responseElements = $Driver.FindElements([OpenQA.Selenium.By]::CssSelector($ResponseSelector))
                
                if ($responseElements.Count -gt 0) {
                    # সর্বশেষ রেসপন্সের টেক্সট পান (Get text from latest response)
                    $currentText = $responseElements[-1].Text
                    
                    if ($currentText -eq $previousText -and $currentText.Length -gt 0) {
                        $stableCount++
                        Write-LogDebug "Text stable ($stableCount/$requiredStableChecks)"
                        
                        if ($stableCount -ge $requiredStableChecks) {
                            Write-LogInfo "Text stabilized after $([math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)) seconds"
                            return $true
                        }
                    } else {
                        $stableCount = 0
                        $previousText = $currentText
                    }
                }
                
            } catch {
                Write-LogDebug "Response element not found yet..."
            }
            
            Start-Sleep -Seconds $CheckInterval
        }
        
        Write-LogWarning "Text did not stabilize within timeout"
        return $false
        
    } catch {
        Write-LogError "Error in Wait-ForTextStability: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Wait-UsingMutationObserver - DOM মিউটেশন অবজার্ভার ব্যবহার করে অপেক্ষা করুন
    
.DESCRIPTION
    JavaScript MutationObserver ব্যবহার করে DOM পরিবর্তন মনিটর করে
    Uses JavaScript MutationObserver to monitor DOM changes
    
.EXAMPLE
    Wait-UsingMutationObserver -Driver $driver -TargetSelector ".response-container"
#>
function Wait-UsingMutationObserver {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxSeconds = 180,
        
        [Parameter(Mandatory = $false)]
        [string]$TargetSelector = "body"
    )
    
    try {
        Write-LogDebug "Setting up DOM MutationObserver..."
        
        # JavaScript কোড: MutationObserver সেটআপ (JavaScript code: MutationObserver setup)
        $observerScript = @"
return new Promise((resolve) => {
    let timeout;
    let observer = new MutationObserver(() => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
            observer.disconnect();
            resolve(true);
        }, 3000);  // 3 seconds of no changes = stable
    });
    
    const target = document.querySelector('$TargetSelector');
    if (target) {
        observer.observe(target, {
            childList: true,
            subtree: true,
            characterData: true
        });
        
        // ম্যাক্সিমাম টাইমআউট সেট করুন (Set maximum timeout)
        setTimeout(() => {
            observer.disconnect();
            resolve(false);
        }, $MaxSeconds * 1000);
    } else {
        resolve(false);
    }
});
"@
        
        # Async script execute করুন (Execute async script)
        $result = $Driver.ExecuteAsyncScript($observerScript)
        
        if ($result) {
            Write-LogInfo "DOM mutations stabilized"
            return $true
        } else {
            Write-LogWarning "MutationObserver timed out"
            return $false
        }
        
    } catch {
        Write-LogError "Error in Wait-UsingMutationObserver: $_"
        return $false
    }
}

#endregion

#region Network Wait Functions

<#
.SYNOPSIS
    Wait-ForNetworkIdle - নেটওয়ার্ক আইডল হওয়ার জন্য অপেক্ষা করুন
    
.DESCRIPTION
    নেটওয়ার্ক অ্যাক্টিভিটি বন্ধ হওয়া পর্যন্ত অপেক্ষা করে (পেজ লোড সম্পূর্ণ)
    Waits until network activity stops (page load complete)
    
.PARAMETER Driver
    Selenium WebDriver অবজেক্ট
    
.PARAMETER IdleTime
    আইডল বিবেচনার জন্য কত সেকেন্ড (Seconds to consider as idle)
    
.EXAMPLE
    Wait-ForNetworkIdle -Driver $driver -IdleTime 2
    
.NOTES
    TODO: Implement using Chrome DevTools Protocol (CDP)
    Currently uses document.readyState as fallback
#>
function Wait-ForNetworkIdle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxSeconds = 60,
        
        [Parameter(Mandatory = $false)]
        [int]$IdleTime = 2
    )
    
    try {
        Write-LogDebug "Waiting for network idle..."
        
        $startTime = Get-Date
        
        while (((Get-Date) - $startTime).TotalSeconds -lt $MaxSeconds) {
            # document.readyState চেক করুন (Check document.readyState)
            $readyState = $Driver.ExecuteScript("return document.readyState;")
            
            if ($readyState -eq "complete") {
                Start-Sleep -Seconds $IdleTime
                
                # পুনরায় চেক করুন (Check again)
                $readyStateAfter = $Driver.ExecuteScript("return document.readyState;")
                if ($readyStateAfter -eq "complete") {
                    Write-LogInfo "Network idle detected"
                    return $true
                }
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        Write-LogWarning "Network did not become idle within timeout"
        return $false
        
    } catch {
        Write-LogError "Error in Wait-ForNetworkIdle: $_"
        return $false
    }
}

#endregion

#region Page Navigation Wait Functions

<#
.SYNOPSIS
    Wait-ForPageLoad - পেজ লোড সম্পূর্ণ হওয়ার জন্য অপেক্ষা করুন
    
.DESCRIPTION
    পেজ সম্পূর্ণভাবে লোড হওয়া পর্যন্ত অপেক্ষা করে
    Waits until page is completely loaded
    
.EXAMPLE
    Wait-ForPageLoad -Driver $driver
#>
function Wait-ForPageLoad {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Driver,
        
        [Parameter(Mandatory = $false)]
        [int]$Timeout = 60
    )
    
    try {
        Write-LogDebug "Waiting for page load..."
        
        $startTime = Get-Date
        
        while (((Get-Date) - $startTime).TotalSeconds -lt $Timeout) {
            $readyState = $Driver.ExecuteScript("return document.readyState;")
            
            if ($readyState -eq "complete") {
                Write-LogInfo "Page loaded successfully"
                return $true
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        Write-LogWarning "Page load timeout"
        return $false
        
    } catch {
        Write-LogError "Error waiting for page load: $_"
        return $false
    }
}

#endregion

#region Export Functions

# এই ফাংশনগুলো export করুন (Export these functions)
Export-ModuleMember -Function @(
    'Wait-ForElement',
    'Wait-ForAIResponse',
    'Wait-ForLoadingComplete',
    'Wait-ForTextStability',
    'Wait-UsingMutationObserver',
    'Wait-ForNetworkIdle',
    'Wait-ForPageLoad'
)

#endregion

<#
.NOTES
    Future Improvements / ভবিষ্যৎ উন্নতি:
    ----------------------------------------
    TODO: Implement Chrome DevTools Protocol (CDP) for network monitoring
    TODO: Add custom wait conditions with lambda functions
    TODO: Add screenshot capture on wait timeout
    TODO: Add retry mechanism with exponential backoff
    TODO: Add performance metrics collection during waits
    TODO: Implement element visibility percentage check
    TODO: Add support for iframe switching and waiting
    TODO: Implement adaptive timeout based on historical data
    TODO: Add visual regression detection during wait
    TODO: Implement scroll into view before element interaction
#>
