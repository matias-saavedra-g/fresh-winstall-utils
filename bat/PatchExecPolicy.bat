@echo off

GOTO EndComment
<!--*************************************************
Installation Notes
Location: Chile
Notes: Created by matias-saavedra-g for using PowerShell scripts in Windows 10.
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

echo Setting PowerShell execution policy to RemoteSigned...

:: Set the execution policy
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"

:: Verify the execution policy
powershell -Command "Get-ExecutionPolicy -List"

echo Execution policy has been set to RemoteSigned.
pause