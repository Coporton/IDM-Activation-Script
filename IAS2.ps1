# Define URLs and file paths
$installerUrl = "https://mirror2.internetdownloadmanager.com/idman642build25.exe"
$installerPath = "$env:TEMP\idman642build25.exe"

$idmanExeUrl = "https://raw.githubusercontent.com/Coporton/IDM-Activation-Script/refs/heads/main/IDMan.exe"
$idmanExePath = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"

$regFileUrl = "https://raw.githubusercontent.com/Coporton/IDM-Activation-Script/refs/heads/main/DownloadManager.reg"
$regFilePath = "$env:TEMP\DownloadManager.reg"

# Download the installer
Write-Host "Downloading IDM installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install IDM normally
Write-Host "Installing IDM normally..."
Start-Process -FilePath $installerPath -NoNewWindow -Wait

# Download the new IDMan.exe
Write-Host "Downloading new IDMan.exe..."
Invoke-WebRequest -Uri $idmanExeUrl -OutFile $idmanExePath -UseBasicParsing

# Download the registry file
Write-Host "Downloading registry file..."
Invoke-WebRequest -Uri $regFileUrl -OutFile $regFilePath -UseBasicParsing

# Apply the registry file
Write-Host "Applying registry settings..."
Start-Process -FilePath "regedit.exe" -ArgumentList "/s $regFilePath" -NoNewWindow -Wait

# Cleanup
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $installerPath, $regFilePath -Force

Write-Host "Process completed!"
