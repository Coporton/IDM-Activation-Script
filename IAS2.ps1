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

# Download the IDM installer
Write-Host "Downloading IDM installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install IDM
Write-Host "Installing IDM..."
Start-Process -FilePath $installerPath -Wait

# Verify installation was successful
if (Test-Path $idmFolderPath) {
    Write-Host "IDM installation completed successfully."
} else {
    Write-Host "IDM installation failed. Please check the installer and try again."
    exit
}

# Download the new IDMan.exe file
Write-Host "Downloading new IDMan.exe..."
$idmanExePath = "$idmFolderPath\IDMan.exe"
Invoke-WebRequest -Uri $idmanExeUrl -OutFile $idmanExePath -UseBasicParsing

# Download the registry file
Write-Host "Downloading registry file..."
$regFilePath = "$env:TEMP\DownloadManager.reg"
Invoke-WebRequest -Uri $regFileUrl -OutFile $regFilePath -UseBasicParsing

# Apply the registry file
Write-Host "Applying registry settings..."
Start-Process -FilePath "regedit.exe" -ArgumentList "/s $regFilePath" -Wait

# Cleanup temporary files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $installerPath, $regFilePath -Force

Write-Host "Process completed successfully!"
