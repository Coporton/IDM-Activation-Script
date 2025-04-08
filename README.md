# **IDM Activation Script (Activator + Registry Cleaner)**

IDM Activation Script is a tool designed to activate Internet Download Manager (IDM) for free, allowing users to bypass trial period restrictions and enjoy the full version without purchasing a license.

### 📝 **Latest Verison**
- Coporton IDM Activation Script 2.2.1

## 💪 **Features**

- ✅ Activate Internet Download Manager for free.
- 🛠 Simple and easy-to-use interface.
- 📂 Compatible with multiple versions of IDM.
- 💻 Lightweight and fast.

## 🛠️ **Installation**

### **Method 1 (Recommended)**
1. **Open PowerShell**:
   - Right-click the Start menu and select **Windows PowerShell** or **Windows Terminal**.
   - If prompted by User Account Control (UAC), click **Yes** to allow PowerShell to run with administrative privileges.

2. **Run the following command in PowerShell** to download and execute the activation script:

   ```powershell
   irm https://coporton.com/ias | iex
   ```

### **Method 2**
1. **Download**: Obtain the latest version of the tool from the [releases page](https://github.com/Coporton/IDM-Activation-Script/releases).
2. **Extract**: Unzip the downloaded file to a directory of your choice.

## 💻 **Usage**

### 1. Run the Script:
- Double-click on `IASL.cmd` to execute it. The script will automatically request administrative privileges if needed, so you no longer need to manually select "Run as Administrator."
- If prompted by User Account Control (UAC), click **Yes** to grant the necessary permissions.
- Once elevated, the script will continue running with the appropriate permissions for file operations.

### 2. Follow the On-Screen Instructions:
- Choose an option from the menu:
  - `1` to Download Latest IDM Version.
  - `2` Clean Previous IDM Registry Entries.
  - `3` to Activate Internet Download Manager.
  - `4` to Extra FileTypes Extensions.
  - `5` to Do Everything (3 + 4).
  - `6` to exit.
- If you select `5`, the script will copy the necessary files to the appropriate directory and provide feedback on the operation status.

## ✅ **Troubleshooting**

- **Administrative Privileges**: If the script does not prompt for administrative rights, ensure you are running it with the required permissions by right-clicking and selecting "Run as Administrator."
- **File Paths**: Verify that the `data.bin`, `dataHlp.bin`, `Registry.bin`, `extensions.bin`, and `banner_art.txt` files are correctly placed in the `src` directory.
- **Registered with a Fake Serial**: Don't worry! Use a trusted third-party uninstaller like IObit Uninstaller, and then use this script [IObit Uninstaller Activation Script](https://github.com/Coporton/IObit-Uninstaller-Activation-Script) to activate it and ensure all files, including registry entries, are removed.

## 📄 **BIN Files**

### These files are not encrypted; you can rename them to view the source file:

- `data.bin` - Contains a activated version of IDMan.exe.
- `dataHlp.bin` - Contains a help support version of IDMGrHlp.exe.
- `Registry.bin` - Registry values to activate Internet Download Manager.
- `extensions.bin` - Registry entries for extra Internet Download Manager file extensions.

## 📜 **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ℹ️ **Acknowledgments**

- Special thanks to AI, that was instrumental in this script's functionality.

## ❓ **Contact**

For questions or support, please open an issue on the GitHub repository.
