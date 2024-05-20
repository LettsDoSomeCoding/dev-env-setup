# Set execution policy so that the script can run successfully
Set-ExecutionPolicy Bypass -Scope Process -Force

# Function to check if a program is installed
function Is-Installed($name) {
    Get-Command $name -ErrorAction SilentlyContinue -CommandType Application
}

# Function to set WSL as default profile in Windows Terminal
function Set-WSLDefaultProfile {
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsPath) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $ubuntuProfile = $settings.profiles.list | Where-Object { $_.name -eq "Ubuntu-22.04" }
        if ($ubuntuProfile) {
            $settings.profiles.defaults = @{ source = $ubuntuProfile.source; name = $ubuntuProfile.name }
            $settings.defaultProfile = $ubuntuProfile.guid
            $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath
            Write-Host "Set Ubuntu-22.04 as the default profile in Windows Terminal."
        } else {
            Write-Host "Ubuntu-22.04 profile not found in Windows Terminal settings."
        }
    } else {
        Write-Host "Windows Terminal settings file not found."
    }
}

# Install Git using winget
if (-not (Is-Installed 'git')) {
    winget install --id Git.Git -e --source winget
}

# Install OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install Visual Studio Code using winget
if (-not (Is-Installed 'code')) {
    winget install --id Microsoft.VisualStudioCode -e --source winget
}

# Install Windows Terminal using winget
if (-not (Is-Installed 'wt')) {
    winget install --id Microsoft.WindowsTerminal -e --source winget
}

# Variable to track if WSL was installed
$wslInstalled = $false

# Install WSL and set up Ubuntu
if (-not (Is-Installed 'wsl')) {
    # Enable WSL feature
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    # Enable Virtual Machine Platform feature
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

    # Install Ubuntu 22.04
    winget install --id Canonical.Ubuntu.2204 -e --source winget

    # Set WSL 2 as default
    wsl --set-default-version 2

    $wslInstalled = $true
    Write-Host "WSL is installed. Please restart your computer to complete the installation."
} else {
    Write-Host "WSL is already installed."
}

Write-Host "Git, OpenSSH Client, Visual Studio Code, Windows Terminal, and WSL installation complete. The next step should be adding your SSH key to ~/.ssh/. Happy coding!"

# Prompt to restart the computer if WSL was installed
if ($wslInstalled) {
    $setWSLasDefaultTerminal = Read-Host "Would you like to set WSL as the default profile of Windows Terminal? (yes/no)"

    if ($setWSLasDefaultTerminal -eq 'yes' -or $setWSLasDefaultTerminal -eq 'y') {
        Set-WSLDefaultProfile
    }

    $restart = Read-Host "Would you like to restart your computer now? (yes/no)"
    if ($restart -eq 'yes' -or $restart -eq 'y') {
        Restart-Computer
    } else {
        Write-Host "Please restart your computer at your convenience to complete the WSL installation."
    }
}
