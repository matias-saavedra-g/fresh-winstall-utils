<#
.SYNOPSIS
This script runs the first time a user logs in to Windows and performs various configurations and installations.

.DESCRIPTION
This script is designed to be run during the first logon of a user on a Windows system. It performs the following tasks:
- Self-elevates the prompt if it is not already elevated.
- Disables User Account Control (UAC) notifications.
- Disables startup programs.
- Applies essential tweaks to disable certain features and settings.
- Installs Winget and its dependencies.
- Installs various applications using Winget.
- Preconfigures a setup.exe to download and install Office Standard 2021.

.PARAMETER None

.EXAMPLE
.\firstlogon.ps1

.NOTES
- This script should be run with administrative privileges.
- Some settings may require a system restart to take effect.
- The script assumes that the necessary files for Winget and Office Standard 2021 are available at the specified locations.
- The script may take some time to complete depending on the system and network conditions.
#>

# -------------------------------------------------------------------------------------------- #
## Self-elevates this prompt in case it is not already elevated
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

## Never notifies UAC ever
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -ErrorAction SilentlyContinue

## Disables all the startup programs from Windows
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | ForEach-Object {Remove-ItemProperty -Path $_.PSPath -Name $_.Name}

# -------------------------------------------------------------------------------------------- #
## Apply some essential tweaks
<#
The script disables the following features and settings:
- SilentInstalledAppsEnabled
- AllowTelemetry
- EnableActivityFeed
- PublishUserActivities
- UploadUserActivities
- AppCaptureEnabled
- GameDVR_Enabled
- Hibernation
- HomeGroupListener service
- HomeGroupProvider service
- Location and Sensors
- Storage Sense
- Teredo
- AutoConnectAllowedOEM
- MouseSpeed
- MouseThreshold1
- MouseThreshold2
- HiberbootEnabled
#>
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -ErrorAction SilentlyContinue# SilentInstalledAppsEnabled has been set to 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
powercfg hibernate off -ErrorAction SilentlyContinue
Stop-Service -Name HomeGroupListener -ErrorAction SilentlyContinue
Set-Service -Name HomeGroupListener -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name HomeGroupProvider -ErrorAction SilentlyContinue
Set-Service -Name HomeGroupProvider -StartupType Disabled -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 0 -ErrorAction SilentlyContinue
Set-NetTeredoConfiguration -Type Disabled -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -ErrorAction SilentlyContinue

# -------------------------------------------------------------------------------------------- #
## Install Winget according to Microsoft Documentation
<#
This script downloads and installs WinGet and its dependencies, 
including Microsoft.VCLibs.x64.14.00.Desktop.appx, 
Microsoft.UI.Xaml.2.8.x64.appx, and 
Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle.
#>
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

## Install the applications using Winget
# Installs WingetUI from Github
winget install --id=SomePythonThings.WingetUIStore -e
# Installs Adobe Acrobat Reader PDF
winget install --id=Adobe.AdobeAcrobatReaderDC -e
# Installs 7-zip
winget install --id=7zip.7zip -e
# Installs MPC-HC
winget install --id=mpc-hc.MPC-HC -e

## Now preconfigures a setup.exe which downloads from web Office Standard 2021 and installs it
<#
XML Configuration for Office Standard 2021

<Configuration ID="1dfe5bff-9288-461f-b1fd-3ed6dcd4c96f">
<Add OfficeClientEdition="64" Channel="PerpetualVL2021">
<Product ID="Standard2021Volume" PIDKEY="KDX7X-BNVR8-TXXGX-4Q7Y8-78VT3">
<Language ID="MatchOS"/>
<ExcludeApp ID="OneDrive"/>
</Product>
</Add>
<Property Name="SharedComputerLicensing" Value="0"/>
<Property Name="FORCEAPPSHUTDOWN" Value="TRUE"/>
<Property Name="DeviceBasedLicensing" Value="0"/>
<Property Name="SCLCacheOverride" Value="0"/>
<Property Name="AUTOACTIVATE" Value="1"/>
<Updates Enabled="TRUE"/>
<RemoveMSI/>
<Display Level="None" AcceptEULA="TRUE"/>
</Configuration>
#>
$OfficeConfig = @"
<Configuration ID="1dfe5bff-9288-461f-b1fd-3ed6dcd4c96f">
<Add OfficeClientEdition="64" Channel="PerpetualVL2021">
<Product ID="Standard2021Volume" PIDKEY="KDX7X-BNVR8-TXXGX-4Q7Y8-78VT3">
<Language ID="MatchOS"/>
<ExcludeApp ID="OneDrive"/>
</Product>
</Add>
<Property Name="SharedComputerLicensing" Value="0"/>
<Property Name="FORCEAPPSHUTDOWN" Value="TRUE"/>
<Property Name="DeviceBasedLicensing" Value="0"/>
<Property Name="SCLCacheOverride" Value="0"/>
<Property Name="AUTOACTIVATE" Value="1"/>
<Updates Enabled="TRUE"/>
<RemoveMSI/>
<Display Level="None" AcceptEULA="TRUE"/>
</Configuration>
"@
$OfficeConfig | Out-File -FilePath "C:\Windows\Temp\OfficeConfig.xml" -Encoding utf8
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=866036" -OutFile "C:\Windows\Temp\OfficeSetup.exe"
Start-Process -FilePath "C:\Windows\Temp\OfficeSetup.exe" -ArgumentList "/configure C:\Windows\Temp\OfficeConfig.xml" -Wait

# -------------------------------------------------------------------------------------------- #
# End of the script