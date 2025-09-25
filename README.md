# win11-autopilot-tools
A repository of files that are useful for installing Windows 11 and getting the Autopilot hash

## win11-usb
### Usage
1. Create a Windows 11 installation USB using the [Media Creation Tool](https://support.microsoft.com/en-au/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)
2. When the USB stick has been created, copy the contents of `win11-usb` to the root of the folder (so that `OOBE.bat` is at the top level of your USB stick)
3. Plug in ethernet, and power, then boot from the USB stick. `autounattend.xml` will automatically install Windows using the Windows 11 Pro key. It will also default the region to English (Australian). ***BE CAREFUL, AS THE INSTALLATION STARTS AUTOMATICALLY AND WILL WIPE THE ENTIRE MACHINE!***
4. When Windows has installed, press `Shift+F10` (you might need to use `FN+Shift+F10`) and run `D:\OOBE.bat`
5. 