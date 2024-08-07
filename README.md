# Software Installation and Tweaks Script

This PowerShell script provides a graphical user interface (GUI) for performing various software installation and system tweak tasks on a Windows machine. The script includes buttons for running specific tasks such as disabling startup programs, installing Chocolatey, running activation scripts, and applying essential system tweaks.

## Features

- **Run CTT Win Utils Script**: Executes the Chris Titus Tech Windows Utilities script.
- **Disable All Startup Programs**: Disables all startup programs to improve boot time.
- **Install Chocolatey**: Installs Chocolatey, a package manager for Windows.
- **Install Chocolatey Package**: Installs a specified Chocolatey package.
- **Run Microsoft Activation Scripts**: Runs Microsoft Activation Scripts to activate Windows.
- **Apply Essential Tweaks**: Applies essential system tweaks for better performance.
- **Set Folder Options**: Sets preferred folder options in Windows Explorer.

## Prerequisites

- Windows PowerShell
- Administrative privileges to run certain tasks

## Usage

1. **Clone the Repository**: Clone this repository to your local machine.
    ```sh
    git clone <repository-url>
    ```

2. **Run the Script**: Open PowerShell with administrative privileges and run the script.
    ```sh
    cd <repository-directory>
    .\FreshWinstallUtils.ps1
    ```

3. **Interact with the GUI**: Use the buttons in the GUI to perform the desired tasks.

## Tooltips

Each button in the GUI has a tooltip that explains its function when hovered over.

- **Run CTT Win Utils Script**: Runs the Chris Titus Tech Windows Utilities script.
- **Disable All Startup Programs**: Disables all startup programs to improve boot time.
- **Install Chocolatey**: Installs Chocolatey, a package manager for Windows.
- **Install Chocolatey Package**: Installs a specified Chocolatey package.
- **Run Microsoft Activation Scripts**: Runs Microsoft Activation Scripts to activate Windows.
- **Apply Essential Tweaks**: Applies essential system tweaks for better performance.
- **Set Folder Options**: Sets preferred folder options in Windows Explorer.

## Example

```powershell
# Import necessary namespaces
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Software Installation and Tweaks"
$form.Size = New-Object System.Drawing.Size(400, 600)

# Create a tooltip object
$tooltip = New-Object System.Windows.Forms.ToolTip

# Create buttons and checkboxes
$btnCTTScript = New-Object System.Windows.Forms.Button
$btnCTTScript.Text = "Run CTT Win Utils Script"
$btnCTTScript.Location = New-Object System.Drawing.Point(10, 10)
$tooltip.SetToolTip($btnCTTScript, "Runs the Chris Titus Tech Windows Utilities script.")

$btnDisableStartup = New-Object System.Windows.Forms.Button
$btnDisableStartup.Text = "Disable All Startup Programs"
$btnDisableStartup.Location = New-Object System.Drawing.Point(10, 50)
$tooltip.SetToolTip($btnDisableStartup, "Disables all startup programs to improve boot time.")

$btnInstallChoco = New-Object System.Windows.Forms.Button
$btnInstallChoco.Text = "Install Chocolatey"
$btnInstallChoco.Location = New-Object System.Drawing.Point(10, 90)
$tooltip.SetToolTip($btnInstallChoco, "Installs Chocolatey, a package manager for Windows.")

$btnInstallPackage = New-Object System.Windows.Forms.Button
$btnInstallPackage.Text = "Install Chocolatey Package"
$btnInstallPackage.Location = New-Object System.Drawing.Point(10, 130)
$tooltip.SetToolTip($btnInstallPackage, "Installs a specified Chocolatey package.")

$btnMASScript = New-Object System.Windows.Forms.Button
$btnMASScript.Text = "Run Microsoft Activation Scripts"
$btnMASScript.Location = New-Object System.Drawing.Point(10, 170)
$tooltip.SetToolTip($btnMASScript, "Runs Microsoft Activation Scripts to activate Windows.")

$btnEssentialTweaks = New-Object System.Windows.Forms.Button
$btnEssentialTweaks.Text = "Apply Essential Tweaks"
$btnEssentialTweaks.Location = New-Object System.Drawing.Point(10, 210)
$tooltip.SetToolTip($btnEssentialTweaks, "Applies essential system tweaks for better performance.")

$btnFolderOptions = New-Object System.Windows.Forms.Button
$btnFolderOptions.Text = "Set Folder Options"
$btnFolderOptions.Location = New-Object System.Drawing.Point(10, 250)
$tooltip.SetToolTip($btnFolderOptions, "Sets preferred folder options in Windows Explorer.")

# Add controls to the form
$form.Controls.Add($btnCTTScript)
$form.Controls.Add($btnDisableStartup)
$form.Controls.Add($btnInstallChoco)
$form.Controls.Add($btnInstallPackage)
$form.Controls.Add($btnMASScript)
$form.Controls.Add($btnEssentialTweaks)
$form.Controls.Add($btnFolderOptions)

# Define button click actions
$btnCTTScript.Add_Click({ CTTScript })
$btnDisableStartup.Add_Click({ Disable-AllStartupPrograms })
$btnInstallChoco.Add_Click({ Install-Choco })
$btnInstallPackage.Add_Click({ Install-ChocolateyPackage -PackageName "example-package" })
$btnMASScript.Add_Click({ MASScript })
$btnEssentialTweaks.Add_Click({ Set-EssentialTweaks })
$btnFolderOptions.Add_Click({ Set-FolderOptions })

# Show the form
$form.ShowDialog()