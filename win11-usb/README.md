## win11-usb
This folder contains scripts that help you install Windows and get the autopilot hardware hash

### Usage
1. Create a Windows 11 installation USB using the [Media Creation Tool](https://support.microsoft.com/en-au/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)
2. When the USB stick has been created, copy the contents of `win11-usb` to the root of the folder (so that `OOBE.bat` is at the top level of your USB stick)
3. Edit `$GroupTag` in `Get-Autopilot-Hash.ps1` as appropriate. If you're not sure what the group tag is, read the Microsoft Learn documentation on group tags, policy sets and dynamic groups in Intune.
3. Plug in ethernet, and power, then boot from the USB stick. `autounattend.xml` will automatically install Windows using the Windows 11 Pro key. It will also default the region to English (Australian). ***BE CAREFUL, AS THE INSTALLATION STARTS AUTOMATICALLY AND WILL WIPE THE ENTIRE MACHINE!***
4. When Windows has installed, press `Shift+F10` (you might need to use `FN+Shift+F10`) and run `D:` followed by `OOBE.bat`
5. Repeat steps 3 and 4 for each laptop you have.
6. `autpilot.csv` can then be uploaded to Intune
7. Start the laptop again, and press Windows key 5 times on the OOBE screen. Pick the autopilot option and wait for the machine to complete.
    7a. You might need to use an unfiltered internet connection, and / or wait 24 hours for the machines to be properly uploaded and updated in Intune.