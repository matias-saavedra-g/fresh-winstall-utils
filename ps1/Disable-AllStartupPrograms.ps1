# Function to disable all startup programs
function Disable-AllStartupPrograms {
    try {
        Get-CimInstance -ClassName Win32_StartupCommand | ForEach-Object {
            Set-CimInstance -InputObject $_ -Property @{Command = ""}
        }
    } catch {
        Write-Host "Failed to disable startup programs" -ForegroundColor Red
    }
}