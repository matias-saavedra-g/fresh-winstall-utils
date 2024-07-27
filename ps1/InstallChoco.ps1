# Function definitions for additional buttons
function InstallChoco {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}