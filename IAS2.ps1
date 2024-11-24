# Define paths
$installerPath = "$env:TEMP\idman642build25.exe"
$idmFolderPath = "C:\Program Files (x86)\Internet Download Manager"

# Function to uninstall IDM if already installed
function Uninstall-IDM {
    Write-Host "Internet Download Manager is already installed."
    $choice = Read-Host "Do you want to uninstall it? (Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        # Attempt to uninstall IDM
        Write-Host "Uninstalling IDM..."
        $uninstallKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        $idmUninstallPath = Get-ItemProperty -Path "$uninstallKey\*" | Where-Object { $_.DisplayName -match "Internet Download Manager" } | Select-Object -ExpandProperty UninstallString
        
        if ($idmUninstallPath) {
            Start-Process -FilePath $idmUninstallPath -ArgumentList "/S" -Wait
            Write-Host "IDM has been uninstalled."
        } else {
            Write-Host "IDM uninstall entry not found. Please uninstall manually."
            exit
        }
    } else {
        Write-Host "Please uninstall IDM before running this script again."
        exit
    }
}

# Check if IDM is already installed
if (Test-Path $idmFolderPath) {
    Uninstall-IDM
}

# Define URLs
$installerUrl = "https://mirror2.internetdownloadmanager.com/idman642build25.exe"
$idmanExeUrl = "https://raw.githubusercontent.com/Coporton/IDM-Activation-Script/refs/heads/main/IDMan.exe"
$regFileUrl = "https://raw.githubusercontent.com/Coporton/IDM-Activation-Script/refs/heads/main/DownloadManager.reg"

# Download the Internet Download Manager installer
Write-Host "Downloading Internet Download Manager installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install Internet Download Manager
Write-Host "Installing Internet Download Manager..."
Start-Process -FilePath $installerPath -Wait

# Verify installation was successful
if (Test-Path $idmFolderPath) {
    Write-Host "Internet Download Manager installation completed successfully."
} else {
    Write-Host "Internet Download Manager installation failed. Please check the installer and try again."
    exit
}

# Kill IDMan.exe process if running
Write-Host "Checking for running IDMan.exe process..."
$idmanProcess = Get-Process -Name "IDMan" -ErrorAction SilentlyContinue
if ($idmanProcess) {
    Write-Host "IDMan.exe is running. Terminating process..."
    Stop-Process -Name "IDMan" -Force
    Write-Host "Running Internet Download Manager has been terminated."
} else {
    Write-Host "No running IDMan.exe process found."
}

# Download the new IDMan.exe file
Write-Host "Internet Download Manager is getting ready for you..."
$idmanExePath = "$idmFolderPath\IDMan.exe"
Invoke-WebRequest -Uri $idmanExeUrl -OutFile $idmanExePath -UseBasicParsing
Write-Host "Internet Download Manager is almost ready."

# Download the registry file
Write-Host "Internet Download Manager is almost ready.."
Write-Host "Internet Download Manager is almost ready..."
$regFilePath = "$env:TEMP\DownloadManager.reg"
Invoke-WebRequest -Uri $regFileUrl -OutFile $regFilePath -UseBasicParsing

# Apply the registry file
Write-Host "Internet Download Manager is almost ready...."
Start-Process -FilePath "regedit.exe" -ArgumentList "/s $regFilePath" -Wait

# Cleanup temporary files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $installerPath, $regFilePath -Force

# Random Serial Display
$serials = @(
    "RLDGN-OV9WU-5W589-6VZH1",
    "HUDWE-UO689-6D27B-YM28M",
    "UK3DV-E0MNW-MLQYX-GENA1",
    "398ND-QNAGY-CMMZU-ZPI39",
    "GZLJY-X50S3-0S20D-NFRF9",
    "W3J5U-8U66N-D0B9M-54SLM",
    "EC0Q6-QN7UH-5S3JB-YZMEK",
    "UVQW0-X54FE-QW35Q-SNZF5",
    "FJJTJ-J0FLF-QCVBK-A287M",
    "XONF7-PMUOL-HU7P4-D1QQX",
    "N0Z90-KJTTW-7TZO4-I27A1",
    "Y5LUM-NFE0Q-GJR2L-5B86I",
    "4BTJF-DYNIL-LD8CN-MM8X5",
    "XAGZU-SJ0FO-BDLTK-B3C3V",
    "F9TZ9-P6IGF-SME74-2WP21",
    "CJA0S-K6CO4-R4NPJ-EKNRK"
)
$randomSerial = $serials | Get-Random
Write-Host ""
Write-Host "Use your details in the registration section"
Write-Host "Here is your serial: $randomSerial"

# Run IDM again
Write-Host "Starting Internet Download Manager..."
Start-Process -FilePath $idmanExePath

# Final message
Write-Host "Process completed successfully!"