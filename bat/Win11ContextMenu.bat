@echo off
GOTO EndComment
<!--*************************************************
Created using Windows AFG found at:
;http://www.windowsafg.com

Installation Notes
Location: Chile
Notes: Created by matias-saavedra-g for automating the Windows installation process.
**************************************************-->
:EndComment

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrative privileges confirmed.
) else (
    echo Requesting administrative privileges...
    PowerShell -Command "Start-Process -Verb RunAs -FilePath '%~dpnx0'"
    exit /b
)

:: Restore the context menu from Windows 10
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

echo Context menu restored.
pause
exit