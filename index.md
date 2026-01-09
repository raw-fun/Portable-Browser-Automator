# Portable-Browser-Automator Index

## পরিচিতি
Portable-Browser-Automator (PBA) একটি পোর্টেবল, AI-সমৃদ্ধ ব্রাউজার অটোমেশন টুল। এটি PowerShell, Selenium WebDriver, এবং Portable Chrome browser ভিত্তিক। প্রধান উদ্দেশ্য হলো: ব্যাচ কন্টেন্ট জেনারেশন, বারবার ডেটা প্রসেসিং, গবেষণার অটোমেশন, এবং দীর্ঘ AI চেইনিং।

## ডিরেক্টরি স্ট্রাকচার
- **App/ChromePortable**: পোর্টেবল Chrome ব্রাউজার ও ভাষার ফাইল
- **Drivers/**: chromedriver.exe, version-mapping.json, auto-update.ps1—ড্রাইভার ও আপডেটার
- **Libraries/**: WebDriver.dll, Newtonsoft.Json.dll (.NET ডিপেন্ডেন্সি)
- **Scripts/Core/**: Initialize.ps1, WebDriver-Manager.ps1, Browser-Controller.ps1
- **Scripts/Automation/**: DeepSeek-Automator.ps1, Gemini-Automator.ps1, Generic-AI-Automator.ps1
- **Scripts/Utils/**: Smart-Wait.ps1, Anti-Detection.ps1, Logger.ps1
- **Workspace/UserData/**: ইউজার প্রোফাইল ও ব্রাউজার ডেটা
- **Workspace/Logs/**: অটোমেশন ও error লগ
- **Workspace/Output/responses/**: AI আউটপুট সংরক্ষণ
- **Config/**: config.json, prompts.json, targets.json (মূল কনফিগারেশন)
- **Docs/**: USER-MANUAL.md, API-REFERENCE.md, TROUBLESHOOTING.md
- **Start-Tool.bat**: টুলের লঞ্চার
- **README.md, LICENSE.txt**: পরিচিতি ও লাইসেন্স

## Key Components
- PowerShell Core স্ক্রিপ্ট: initialize, automate, ও utility
- Selenium WebDriver (.dll), Portable Chrome integration
- Anti-Detection, Smart-Wait, Logger

## Automation Workflow
- config.json থেকে সব কনফিগ লোড
- Initialize স্ক্রিপ্ট দিয়ে পরিবেশ তৈরি
- Automation স্ক্রিপ্ট অনুযায়ী DeepSeek/Gemini/Generic AI সাইট অটোমেশন
- Output (AI ও অন্যান্য response) Workspace-এ সংরক্ষণ

## Configuration Files
- config.json: প্রজেক্টের প্রধান কনফিগ
- prompts.json: সংরক্ষিত প্রম্পট
- targets.json: টার্গেট সাইট

## Testing & Monitoring
- Logger.ps1: লগিং ও পারফরমেন্স ট্র্যাকিং, error log
- Test Automation যুক্ত (Smart-Wait, Delay, Action executor)

## Documentation
- USER-MANUAL: ব্যবহারবিধি
- API-REFERENCE: কম্পোনেন্ট ও ফাংশনের বিবরণ
- TROUBLESHOOTING: ত্রুটি মোচনের গা��ড

## Implementation Plan (Phase-wise)
- গবেষণা ও প্রশিক্ষণ
- স্ক্রিপ্ট, কম্পোনেন্ট ও অটোমেশন টেস্ট
- GUI/Batch/Security Audit
- Release Preparation, Versioning

## Success Metrics
- পারফরমেন্স, একিউরেসি, বট-ডিটেকশন
- Error Handling ও Automation Coverage

## License
রিপোজিটরি লাইসেন্স সংক্রান্ত তথ্য LICENSE.txt-তে পাওয়া যায়।