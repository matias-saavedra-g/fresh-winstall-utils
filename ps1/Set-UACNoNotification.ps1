# Function to set UAC to never notify
function Set-UACNoNotification {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        $regName = "ConsentPromptBehaviorUser"
        $regValue = 0
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force -ErrorAction SilentlyContinue
        }
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction SilentlyContinue
        Write-Host "UAC notifications have been disabled for the current user." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set UAC notifications." -ForegroundColor Red
    }
}