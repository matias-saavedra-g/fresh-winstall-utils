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

# Create a form that allows the user to select what software to install and what tweaks to run and then execute them all at once
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "Fresh Windows Install Utilities"
$form.Size = New-Object Drawing.Size(600,500)
$form.StartPosition = "CenterScreen"

# Create checkboxes that install software and run tweaks
$checkboxes = @{}

$checkboxes['AdobeAcrobat'] = New-Object Windows.Forms.CheckBox
$checkboxes['AdobeAcrobat'].Text = "Installs Adobe Acrobat Reader PDF"
$checkboxes['AdobeAcrobat'].AutoSize = $true
$checkboxes['AdobeAcrobat'].Location = New-Object Drawing.Point(10,20)
$form.Controls.Add($checkboxes['AdobeAcrobat'])

$checkboxes['7zip'] = New-Object Windows.Forms.CheckBox
$checkboxes['7zip'].Text = "Installs 7zip"
$checkboxes['7zip'].AutoSize = $true
$checkboxes['7zip'].Location = New-Object Drawing.Point(10,50)
$form.Controls.Add($checkboxes['7zip'])

$checkboxes['Office'] = New-Object Windows.Forms.CheckBox
$checkboxes['Office'].Text = "Installs Office 2019 Pro Plus"
$checkboxes['Office'].AutoSize = $true
$checkboxes['Office'].Location = New-Object Drawing.Point(10,80)
$form.Controls.Add($checkboxes['Office'])

$checkboxes['MPC'] = New-Object Windows.Forms.CheckBox
$checkboxes['MPC'].Text = "Installs MPC-HC"
$checkboxes['MPC'].AutoSize = $true
$checkboxes['MPC'].Location = New-Object Drawing.Point(10,110)
$form.Controls.Add($checkboxes['MPC'])

$checkboxes['DisableStartupPrograms'] = New-Object Windows.Forms.CheckBox
$checkboxes['DisableStartupPrograms'].Text = "Disable all startup programs"
$checkboxes['DisableStartupPrograms'].AutoSize = $true
$checkboxes['DisableStartupPrograms'].Location = New-Object Drawing.Point(10,140)
$form.Controls.Add($checkboxes['DisableStartupPrograms'])

$checkboxes['TaskbarOptions'] = New-Object Windows.Forms.CheckBox
$checkboxes['TaskbarOptions'].Text = "Adjust taskbar settings"
$checkboxes['TaskbarOptions'].AutoSize = $true
$checkboxes['TaskbarOptions'].Location = New-Object Drawing.Point(10,170)
$form.Controls.Add($checkboxes['TaskbarOptions'])

$checkboxes['FolderOptions'] = New-Object Windows.Forms.CheckBox
$checkboxes['FolderOptions'].Text = "Set folder options"
$checkboxes['FolderOptions'].AutoSize = $true
$checkboxes['FolderOptions'].Location = New-Object Drawing.Point(10,200)
$form.Controls.Add($checkboxes['FolderOptions'])

$checkboxes['EssentialTweaks'] = New-Object Windows.Forms.CheckBox
$checkboxes['EssentialTweaks'].Text = "Apply essential tweaks"
$checkboxes['EssentialTweaks'].AutoSize = $true
$checkboxes['EssentialTweaks'].Location = New-Object Drawing.Point(10,230)
$form.Controls.Add($checkboxes['EssentialTweaks'])

$checkboxes['UACNoNotification'] = New-Object Windows.Forms.CheckBox
$checkboxes['UACNoNotification'].Text = "Set UAC to never notify"
$checkboxes['UACNoNotification'].AutoSize = $true
$checkboxes['UACNoNotification'].Location = New-Object Drawing.Point(10,260)
$form.Controls.Add($checkboxes['UACNoNotification'])

# Create buttons that check checkboxes
$buttonSoftware = New-Object Windows.Forms.Button
$buttonSoftware.Text = "Install commonly used software"
$buttonSoftware.Location = New-Object Drawing.Point(300,20)
$buttonSoftware.AutoSize = $true
$form.Controls.Add($buttonSoftware)
$buttonSoftware.Add_Click({
    $checkboxes['AdobeAcrobat'].Checked = $true
    $checkboxes['7zip'].Checked = $true
    $checkboxes['Office'].Checked = $true
    $checkboxes['MPC'].Checked = $true
})

$buttonTweaks = New-Object Windows.Forms.Button
$buttonTweaks.Text = "Run some commonly useful tweaks"
$buttonTweaks.Location = New-Object Drawing.Point(300,50)
$buttonTweaks.AutoSize = $true
$form.Controls.Add($buttonTweaks)
$buttonTweaks.Add_Click({
    $checkboxes['DisableStartupPrograms'].Checked = $true
    $checkboxes['TaskbarOptions'].Checked = $true
    $checkboxes['FolderOptions'].Checked = $true
    $checkboxes['EssentialTweaks'].Checked = $true
    $checkboxes['UACNoNotification'].Checked = $true
})

# Create additional buttons that call functions
$buttonInstallChoco = New-Object Windows.Forms.Button
$buttonInstallChoco.Text = "Install Choco Installer"
$buttonInstallChoco.Location = New-Object Drawing.Point(300,80)
$buttonInstallChoco.AutoSize = $true
$form.Controls.Add($buttonInstallChoco)
$buttonInstallChoco.Add_Click({
    Invoke-Expression "\ps1\InstallChoco.ps1"
})

$buttonExecuteScript1 = New-Object Windows.Forms.Button
$buttonExecuteScript1.Text = "Execute Microsoft Activation Scripts"
$buttonExecuteScript1.Location = New-Object Drawing.Point(300,110)
$buttonExecuteScript1.AutoSize = $true
$form.Controls.Add($buttonExecuteScript1)
$buttonExecuteScript1.Add_Click({
    Invoke-Expression "\ps1\MASScript.ps1"
})

$buttonExecuteScript2 = New-Object Windows.Forms.Button
$buttonExecuteScript2.Text = "Execute CTT Win Utils"
$buttonExecuteScript2.Location = New-Object Drawing.Point(300,140)
$buttonExecuteScript2.AutoSize = $true
$form.Controls.Add($buttonExecuteScript2)
$buttonExecuteScript2.Add_Click({
    Invoke-Expression "\ps1\CTTScript.ps1"
})

$buttonHighPerformancePlan = New-Object Windows.Forms.Button
$buttonHighPerformancePlan.Text = "Configure High Performance Plan"
$buttonHighPerformancePlan.Location = New-Object Drawing.Point(300,170)
$buttonHighPerformancePlan.AutoSize = $true
$form.Controls.Add($buttonHighPerformancePlan)
$buttonHighPerformancePlan.Add_Click({
    Invoke-Expression "\bat\MattiPowerPlan.bat"
})

$buttonExecutionPolicy = New-Object Windows.Forms.Button
$buttonExecutionPolicy.Text = "Configure Execution Policy"
$buttonExecutionPolicy.Location = New-Object Drawing.Point(300,200)
$buttonExecutionPolicy.AutoSize = $true
$form.Controls.Add($buttonExecutionPolicy)
$buttonExecutionPolicy.Add_Click({
    Invoke-Expression "\bat\PatchExecPolicy.bat"
})

# Create OK button
$buttonOK = New-Object Windows.Forms.Button
$buttonOK.Text = "OK"
$buttonOK.Location = New-Object Drawing.Point(10,300)
$form.Controls.Add($buttonOK)
$buttonOK.Add_Click({
    $form.Close()
})

$form.ShowDialog()

# Install software functions
if ($checkboxes['AdobeAcrobat'].Checked) { choco install adobereader }
if ($checkboxes['7zip'].Checked) { choco install 7zip }
if ($checkboxes['Office'].Checked) { choco install office2019proplus }
if ($checkboxes['MPC'].Checked) { choco install mpc-hc }

# Run tweak functions
if ($checkboxes['DisableStartupPrograms'].Checked) { Disable-AllStartupPrograms }
if ($checkboxes['TaskbarOptions'].Checked) { Set-TaskbarOptions }
if ($checkboxes['FolderOptions'].Checked) { Set-FolderOptions }
if ($checkboxes['EssentialTweaks'].Checked) { Set-EssentialTweaks }
if ($checkboxes['UACNoNotification'].Checked) { Set-UACNoNotification }