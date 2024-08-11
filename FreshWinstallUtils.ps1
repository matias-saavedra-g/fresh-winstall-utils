# Ensure the script is run as administrator and then create a form that allows the user to select what software to install and what tweaks to run and then execute them all at once

# Check if user wants to elevate the script
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    # Prompt user for elevation if not already running as administrator
    Write-Host "Do you want to elevate this script? (Type 'elevate')"
    $userInput = Read-Host

    if ($userInput -eq "elevate") {
        # Check if already running as administrator and if not, restart the script as an administrator
        if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "This script will self elevate to run as an Administrator and continue."
            Start-Sleep 1
            Write-Host " Launching in Admin mode" -f DarkRed
            $pwshexe = (Get-Command 'powershell.exe').Source
            Start-Process $pwshexe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
            Exit
        }
    }
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "You need to run this script as an administrator."
    exit
}

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define a variable to store the path to the current script's directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Script path: $scriptPath"

# Define functions to install software and run tweaks

# Function to run CTT Win Utils script
function CTTScript {
    Invoke-RestMethod "https://christitus.com/win" | Invoke-Expression
    Write-Host "CTT Win Utils script has been executed successfully" -ForegroundColor Green
}

# Function to disable all programs from Windows Startup
function Disable-AllStartupPrograms {
    try {
        # Disable startup programs from Win32_StartupCommand
        Get-CimInstance -ClassName Win32_StartupCommand | ForEach-Object {
            Set-CimInstance -InputObject $_ -Property @{Command = ""}
        }

        # Disable startup programs from the registry (Current User)
        $regPathCU = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        if (Test-Path $regPathCU) {
            Get-ItemProperty $regPathCU | ForEach-Object {
                Remove-ItemProperty -Path $regPathCU -Name $_.PSChildName
            }
        }

        # Disable startup programs from the registry (Local Machine)
        $regPathLM = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        if (Test-Path $regPathLM) {
            Get-ItemProperty $regPathLM | ForEach-Object {
                Remove-ItemProperty -Path $regPathLM -Name $_.PSChildName
            }
        }

        # Disable startup programs from the startup folder (Current User)
        $startupFolderCU = [System.Environment]::GetFolderPath('Startup')
        Get-ChildItem -Path $startupFolderCU | ForEach-Object {
            Remove-Item -Path $_.FullName
        }

        # Disable startup programs from the startup folder (All Users)
        $startupFolderAllUsers = [System.Environment]::GetFolderPath('CommonStartup')
        Get-ChildItem -Path $startupFolderAllUsers | ForEach-Object {
            Remove-Item -Path $_.FullName
        }

        Write-Host "All startup programs have been disabled" -ForegroundColor Green
    } catch {
        Write-Host "Failed to disable startup programs" -ForegroundColor Red
    }
}

### I started using Winget to install software instead of Chocolatey, but you can use Chocolatey if you prefer
# Function to install Chocolatey if not already installed
function Install-Choco {
    try{
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey has been installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Chocolatey" -ForegroundColor Red
    }
}

# Function to install a Chocolatey package if it is not already installed, or upgrade it if it was already installed
function Install-ChocolateyPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$PackageName
    )

    # Check if package is already installed
    $chocoList = choco list
    $installedPackages = ($chocoList -split "`r`n") -join " "
    if ($installedPackages -like "*$PackageName*") {
        Write-Host "$PackageName is already installed. Upgrading..." -ForegroundColor Yellow
        choco upgrade $PackageName -y -trace
        Write-Host "$PackageName has been upgraded successfully" -ForegroundColor Green
    } else {
        Write-Host "Installing $PackageName..." -ForegroundColor Yellow
        choco install $PackageName -y -trace
        Write-Host "$PackageName has been installed successfully" -ForegroundColor Green
    }
}
###

# Function to run Microsoft Activation Scripts
function MASScript {
    Invoke-RestMethod "https://get.activated.win" | Invoke-Expression
    write-host "Microsoft Activation Scripts have been executed successfully" -ForegroundColor Green
}

# Function to apply essential tweaks
function Set-EssentialTweaks {
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "SilentInstalledAppsEnabled has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
        write-host "AllowTelemetry has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "EnableActivityFeed has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "PublishUserActivities has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "UploadUserActivities has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "AppCaptureEnabled has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "GameDVR_Enabled has been set to 0" -ForegroundColor Green
        powercfg hibernate off -ErrorAction SilentlyContinue
        Write-Host "Hibernation has been disabled" -ForegroundColor Green
        Stop-Service -Name HomeGroupListener -ErrorAction SilentlyContinue
        Write-Host "HomeGroupListener service has been stopped" -ForegroundColor Green
        Set-Service -Name HomeGroupListener -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "HomeGroupListener service has been disabled" -ForegroundColor Green
        Stop-Service -Name HomeGroupProvider -ErrorAction SilentlyContinue
        Write-Host "HomeGroupProvider service has been stopped" -ForegroundColor Green
        Set-Service -Name HomeGroupProvider -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "HomeGroupProvider service has been disabled" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -ErrorAction SilentlyContinue
        Write-Host "Location services have been disabled" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "Storage Sense has been disabled" -ForegroundColor Green
        Set-NetTeredoConfiguration -Type Disabled -ErrorAction SilentlyContinue
        Write-Host "Teredo has been disabled" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "AutoConnectAllowedOEM has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "MouseSpeed has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "MouseThreshold1 has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "MouseThreshold2 has been set to 0" -ForegroundColor Green
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "HiberbootEnabled has been set to 0" -ForegroundColor Green
        Write-Host "All essential tweaks applied successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to apply some essential tweaks" -ForegroundColor Red
    }
}

# Function to set folder options
function Set-FolderOptions {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "AutoCheckSelect has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "HideFileExt has been set to 0" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "Hidden has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "LaunchTo has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "ShowSyncProviderNotifications has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "NavPaneExpandToCurrentFolder has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "NavPaneShowAllFolders has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowLibraries" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "NavPaneShowLibraries has been set to 1" -ForegroundColor Green
}

# Function to set taskbar options
function Set-TaskbarOptions {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "SearchboxTaskbarMode has been set to 1" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "ShowCortanaButton has been set to 0" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "ShowTaskViewButton has been set to 0" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "PenWorkspaceButtonDesiredVisibility has been set to 0" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "TipbandDesiredVisibility" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "TipbandDesiredVisibility has been set to 0" -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -ErrorAction SilentlyContinue
    Write-Host "ShellFeedsTaskbarViewMode has been set to 2" -ForegroundColor Green
    Stop-Process -Name explorer -Force
    Write-Host "Explorer has been restarted" -ForegroundColor Green
    Start-Process explorer.exe
    Write-Host "Taskbar options have been set successfully" -ForegroundColor Green
}

# Function to set UAC to never notify
function Set-UACNoNotification {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        Write-Host "Setting UAC notifications to never notify..." -ForegroundColor Yellow
        $regName = "ConsentPromptBehaviorUser"
        Write-Host "Setting $regName to 0"
        $regValue = 0
        Write-Host "Setting $regPath\$regName to $regValue"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force -ErrorAction SilentlyContinue
            Write-Host "Created registry path $regPath" -ForegroundColor Green
        }
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction SilentlyContinue
        Write-Host "UAC notifications have been disabled for the current user." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set UAC notifications." -ForegroundColor Red
    }
}

# Function that activates the Windows 10 Ultimate Performance Power Plan
function Set-UltPerformancePlan {
    try {
        # Checks if the ultimate performance power plan already existed
        $powerPlanExists = powercfg -list | Select-String -Pattern "Ultimate Performance" -Quiet
        if ($powerPlanExists) {
            Write-Host "Ultimate Performance Power Plan already exists." -ForegroundColor Yellow
            return
        }
        Write-Host "Setting Ultimate Performance Power Plan..." -ForegroundColor Yellow
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        Write-Host "Ultimate Performance Power Plan has been set successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to set Ultimate Performance Power Plan." -ForegroundColor Red
    }
}

# Create a form that allows the user to select what software to install and what tweaks to run and then execute them all at once
Write-Host "Creating form..." -ForegroundColor Yellow

$form = New-Object Windows.Forms.Form
$form.Text = "Fresh Windows Install Utilities"
$form.Size = New-Object Drawing.Size(850,800)
$form.StartPosition = "CenterScreen"

# Changes the icon of the forms
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$scriptPath\icons\MT.ico")

# Makes the background color of the form Monaco Blue #264375
$form.BackColor = "#264375"

# Makes the default font of the form Arial, 9pt, and Color White
$form.Font = New-Object Drawing.Font("Arial", 9, [Drawing.FontStyle]::Regular)
$form.ForeColor = [Drawing.Color]::White

# Makes the default background color of every button in the form Dark Blue #1A2E4F
$form.DefaultBackColor = "#1A2E4F"

# Creates a title for the checkboxes
$labelTitle = New-Object Windows.Forms.Label
$labelTitle.Font = New-Object Drawing.Font("Arial", 10, [Drawing.FontStyle]::Bold)
$labelTitle.Text = "Select what software to install and what tweaks to run"
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object Drawing.Point(10,10)
$form.Controls.Add($labelTitle)

# Create checkboxes that install software and run tweaks
$checkboxes = @{}

$checkboxes['AdobeAcrobat'] = New-Object Windows.Forms.CheckBox
$checkboxes['AdobeAcrobat'].Text = "Installs Adobe Acrobat Reader PDF"
$checkboxes['AdobeAcrobat'].AutoSize = $true
$checkboxes['AdobeAcrobat'].Location = New-Object Drawing.Point(10,50)
$form.Controls.Add($checkboxes['AdobeAcrobat'])

$checkboxes['7zip'] = New-Object Windows.Forms.CheckBox
$checkboxes['7zip'].Text = "Installs 7-Zip"
$checkboxes['7zip'].AutoSize = $true
$checkboxes['7zip'].Location = New-Object Drawing.Point(10,80)
$form.Controls.Add($checkboxes['7zip'])

$checkboxes['Office'] = New-Object Windows.Forms.CheckBox
$checkboxes['Office'].Text = "Installs Office 2021 Standard"
$checkboxes['Office'].AutoSize = $true
$checkboxes['Office'].Location = New-Object Drawing.Point(10,110)
$form.Controls.Add($checkboxes['Office'])

$checkboxes['MPC'] = New-Object Windows.Forms.CheckBox
$checkboxes['MPC'].Text = "Installs MPC-HC"
$checkboxes['MPC'].AutoSize = $true
$checkboxes['MPC'].Location = New-Object Drawing.Point(10,140)
$form.Controls.Add($checkboxes['MPC'])

$checkboxes['WinGetUI'] = New-Object Windows.Forms.CheckBox
$checkboxes['WinGetUI'].Text = "Installs WinGet UI"
$checkboxes['WinGetUI'].AutoSize = $true
$checkboxes['WinGetUI'].Location = New-Object Drawing.Point(10,170)
$form.Controls.Add($checkboxes['WinGetUI'])

$checkboxes['DisableStartupPrograms'] = New-Object Windows.Forms.CheckBox
$checkboxes['DisableStartupPrograms'].Text = "Disable all startup programs"
$checkboxes['DisableStartupPrograms'].AutoSize = $true
$checkboxes['DisableStartupPrograms'].Location = New-Object Drawing.Point(10,200)
$form.Controls.Add($checkboxes['DisableStartupPrograms'])

$checkboxes['TaskbarOptions'] = New-Object Windows.Forms.CheckBox
$checkboxes['TaskbarOptions'].Text = "Adjust taskbar settings"
$checkboxes['TaskbarOptions'].AutoSize = $true
$checkboxes['TaskbarOptions'].Location = New-Object Drawing.Point(10,230)
$form.Controls.Add($checkboxes['TaskbarOptions'])

$checkboxes['FolderOptions'] = New-Object Windows.Forms.CheckBox
$checkboxes['FolderOptions'].Text = "Set folder options"
$checkboxes['FolderOptions'].AutoSize = $true
$checkboxes['FolderOptions'].Location = New-Object Drawing.Point(10,260)
$form.Controls.Add($checkboxes['FolderOptions'])

$checkboxes['EssentialTweaks'] = New-Object Windows.Forms.CheckBox
$checkboxes['EssentialTweaks'].Text = "Apply essential tweaks"
$checkboxes['EssentialTweaks'].AutoSize = $true
$checkboxes['EssentialTweaks'].Location = New-Object Drawing.Point(10,290)
$form.Controls.Add($checkboxes['EssentialTweaks'])

$checkboxes['UACNoNotification'] = New-Object Windows.Forms.CheckBox
$checkboxes['UACNoNotification'].Text = "Set UAC to never notify"
$checkboxes['UACNoNotification'].AutoSize = $true
$checkboxes['UACNoNotification'].Location = New-Object Drawing.Point(10,320)
$form.Controls.Add($checkboxes['UACNoNotification'])

# Creates a title for the buttons
$labelTitle = New-Object Windows.Forms.Label
$labelTitle.Font = New-Object Drawing.Font("Arial", 10, [Drawing.FontStyle]::Bold)
$labelTitle.Text = "One-Click additional utilities"
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object Drawing.Point(600,10)
$form.Controls.Add($labelTitle)

# Create buttons
$buttonSoftware = New-Object Windows.Forms.Button
$buttonSoftware.Text = "Check commonly used software"
$buttonSoftware.Location = New-Object Drawing.Point(600,50)
$buttonSoftware.AutoSize = $true
$form.Controls.Add($buttonSoftware)
$buttonSoftware.Add_Click({
    $checkboxes['AdobeAcrobat'].Checked = $true
    $checkboxes['7zip'].Checked = $true
    $checkboxes['Office'].Checked = $true
    $checkboxes['MPC'].Checked = $true
})

$buttonTweaks = New-Object Windows.Forms.Button
$buttonTweaks.Text = "Check commonly useful tweaks"
$buttonTweaks.Location = New-Object Drawing.Point(600,80)
$buttonTweaks.AutoSize = $true
$form.Controls.Add($buttonTweaks)
$buttonTweaks.Add_Click({
    $checkboxes['DisableStartupPrograms'].Checked = $true
    $checkboxes['TaskbarOptions'].Checked = $true
    $checkboxes['FolderOptions'].Checked = $true
    $checkboxes['EssentialTweaks'].Checked = $true
    $checkboxes['UACNoNotification'].Checked = $true
})

# Create additional buttons
$buttonInstallWinget = New-Object Windows.Forms.Button
$buttonInstallWinget.Text = "Install Winget"
$buttonInstallWinget.Location = New-Object Drawing.Point(600,110)
$buttonInstallWinget.AutoSize = $true
$form.Controls.Add($buttonInstallWinget)
$buttonInstallWinget.Add_Click({
    # get latest download url
    $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
            Select-Object -ExpandProperty "assets" |
            Where-Object "browser_download_url" -Match '.msixbundle' |
            Select-Object -ExpandProperty "browser_download_url"

    # download
    Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

    # install
    Add-AppxPackage -Path "Setup.msix"

    # delete file
    Remove-Item "Setup.msix"
})

$buttonExecuteScript1 = New-Object Windows.Forms.Button
$buttonExecuteScript1.Text = "Execute Microsoft Activation Scripts"
$buttonExecuteScript1.Location = New-Object Drawing.Point(600,140)
$buttonExecuteScript1.AutoSize = $true
$form.Controls.Add($buttonExecuteScript1)
$buttonExecuteScript1.Add_Click({
    MASScript
})

$buttonExecuteScript2 = New-Object Windows.Forms.Button
$buttonExecuteScript2.Text = "Execute CTT Win Utils"
$buttonExecuteScript2.Location = New-Object Drawing.Point(600,170)
$buttonExecuteScript2.AutoSize = $true
$form.Controls.Add($buttonExecuteScript2)
$buttonExecuteScript2.Add_Click({
    CTTScript
})

$buttonHighPerformancePlan = New-Object Windows.Forms.Button
$buttonHighPerformancePlan.Text = "Set High Performance Plan"
$buttonHighPerformancePlan.Location = New-Object Drawing.Point(600,200)
$buttonHighPerformancePlan.AutoSize = $true
$form.Controls.Add($buttonHighPerformancePlan)
$buttonHighPerformancePlan.Add_Click({
    try {
        # Run the batch file with the correct working directory
        Start-Process -FilePath "$scriptPath\bat\MattiPowerPlan.bat"

    } catch {
        Write-Host "Failed to set High Performance Power Plan." -ForegroundColor Red
    }

})

$buttonExecutionPolicy = New-Object Windows.Forms.Button
$buttonExecutionPolicy.Text = "Patch Execution Policy"
$buttonExecutionPolicy.Location = New-Object Drawing.Point(600,230)
$buttonExecutionPolicy.AutoSize = $true
$form.Controls.Add($buttonExecutionPolicy)
$buttonExecutionPolicy.Add_Click({
    try {
        # Run the batch file with the correct working directory
        Start-Process -FilePath "$scriptPath\bat\PatchExecPolicy.bat"
    } catch {
        Write-Host "Failed to patch execution policy from Powershell." -ForegroundColor Red
    }
})

$buttonUltimatePerformancePlan = New-Object Windows.Forms.Button
$buttonUltimatePerformancePlan.Text = "Enables Ultimate Performance"
$buttonUltimatePerformancePlan.Location = New-Object Drawing.Point(600,260)
$buttonUltimatePerformancePlan.AutoSize = $true
$form.Controls.Add($buttonUltimatePerformancePlan)
$buttonUltimatePerformancePlan.Add_Click({
    Set-UltPerformancePlan
})

$buttonInstallDrivers = New-Object Windows.Forms.Button
$buttonInstallDrivers.Text = "Install Drivers"
$buttonInstallDrivers.Location = New-Object Drawing.Point(600,290)
$buttonInstallDrivers.AutoSize = $true
$form.Controls.Add($buttonInstallDrivers)
$buttonInstallDrivers.Add_Click({
    Start-Process "https://driverpack.io/"
})

$buttonWin11ContextMenu = New-Object Windows.Forms.Button
$buttonWin11ContextMenu.Text = "Restore Context Menu Windows 11"
$buttonWin11ContextMenu.Location = New-Object Drawing.Point(600,320)
$buttonWin11ContextMenu.AutoSize = $true
$form.Controls.Add($buttonWin11ContextMenu)
$buttonWin11ContextMenu.Add_Click({
    try {
        # Run the batch file with the correct working directory
        Start-Process -FilePath "$scriptPath\bat\Win11ContextMenu.bat"

    } catch {
        Write-Host "Failed to restore context menu in Windows 11." -ForegroundColor Red
    }
})

$buttonAbout = New-Object Windows.Forms.Button
$buttonAbout.Text = "About"
$buttonAbout.Location = New-Object Drawing.Point(145,700)
$buttonAbout.AutoSize = $true
$form.Controls.Add($buttonAbout)
$buttonAbout.Add_Click({
    Start-Process "https://sites.google.com/view/mt-homepage"
})
# Adds the icon to the button.
# Load the original image
$originalImage = [System.Drawing.Image]::FromFile("$scriptPath\icons\MT.ico")
# Create a new bitmap with the desired size
$resizedImage = New-Object System.Drawing.Bitmap 13, 13
# Create a graphics object to perform the resizing
$graphics = [System.Drawing.Graphics]::FromImage($resizedImage)
# Set the interpolation mode to high quality
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
# Draw the original image onto the resized bitmap
$graphics.DrawImage($originalImage, 0, 0, 13, 13)
# Dispose of the graphics object
$graphics.Dispose()
# Assign the resized image to the button
$buttonAbout.Image = $resizedImage
$buttonAbout.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$buttonAbout.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight

$buttonWallpapers = New-Object Windows.Forms.Button
$buttonWallpapers.Text = "Wallpapers"
$buttonWallpapers.Location = New-Object Drawing.Point(280,700)
$buttonWallpapers.AutoSize = $true
$form.Controls.Add($buttonWallpapers)
$buttonWallpapers.Add_Click({
    # Suggest wallpapers
    Write-Host "Suggesting wallpapers..." -ForegroundColor Yellow

    Start-Process https://ibb.co/yFzF6hC
    Start-Process https://imgbb.com/r3SRgDT
})

# Create Run All Checked button that installs software and runs tweaks
$buttonRunAll = New-Object Windows.Forms.Button
$buttonRunAll.Text = "Run All Checked"
$buttonRunAll.Location = New-Object Drawing.Point(10,700)
$buttonRunAll.AutoSize = $true
$form.Controls.Add($buttonRunAll)
$buttonRunAll.Add_Click({
    # Install software
    if ($checkboxes['AdobeAcrobat'].Checked) { winget install -e --id Adobe.Acrobat.Reader.32-bit }
    if ($checkboxes['7zip'].Checked) { winget install -e --id 7zip.7zip }
    if ($checkboxes['Office'].Checked) {
# -------------------------------------------------------------------------------------------- #
## Office installation script

# Define the installation directory and configuration file
$installDir = "C:\Install\Office"
$configFile = "C:\Install\Office\configuration.xml"

# Create the installation directory
New-Item -ItemType Directory -Path $installDir -Force

# Download the Office Deployment Tool (ODT)
$odtUrl = "https://aka.ms/OfficeDeploymentTool"
Invoke-WebRequest -Uri $odtUrl -OutFile "$installDir\ODT.exe"

# Run the ODT to extract files
Start-Process -FilePath "$installDir\ODT.exe" -ArgumentList "/extract:$installDir" -Wait

# Create the configuration.xml file
$configXml = @"
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

# Save the configuration file
$configXml | Set-Content -Path $configFile

# Download Office installation files
Start-Process -FilePath "$installDir\setup.exe" -ArgumentList "/download $configFile" -Wait

# Install Office
Start-Process -FilePath "$installDir\setup.exe" -ArgumentList "/configure $configFile" -Wait

Write-Host "Office Standard 2021 installation completed." -ForegroundColor Green

# Clean the installation files and configuration files
Remove-Item -Path $installDir -Recurse -Force

## End of Office installation script
# -------------------------------------------------------------------------------------------- #
    }
    if ($checkboxes['MPC'].Checked) { winget install -e --id clsid2.mpc-hc }
    if ($checkboxes['WinGetUI'].Checked) { winget install -e --id SomePythonThings.WingetUIStore }

    # Run tweaks
    if ($checkboxes['DisableStartupPrograms'].Checked) { Disable-AllStartupPrograms }
    if ($checkboxes['TaskbarOptions'].Checked) { Set-TaskbarOptions }
    if ($checkboxes['FolderOptions'].Checked) { Set-FolderOptions }
    if ($checkboxes['EssentialTweaks'].Checked) { Set-EssentialTweaks }
    if ($checkboxes['UACNoNotification'].Checked) { Set-UACNoNotification }
})

# Create OK button
$buttonOK = New-Object Windows.Forms.Button
$buttonOK.Text = "Close"
$buttonOK.Location = New-Object Drawing.Point(600,700)
$form.Controls.Add($buttonOK)
$buttonOK.Add_Click({
    # Add confirmation box to close the form
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to close the form?", "Close Form", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -eq "Yes") {
        # Close the form
        Write-Host "Closing form..." -ForegroundColor Yellow
        $form.Close()
    }    
})

Write-Host "Opening form..." -ForegroundColor Yellow

$form.ShowDialog()

Write-Host  "Form closed" -ForegroundColor Yellow