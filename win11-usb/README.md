## win11-usb
This folder contains scripts that help you install Windows and get the autopilot hardware hash

### Usage
1. Create a Windows 11 installation USB using the [Media Creation Tool](https://support.microsoft.com/en-au/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)
2. When the USB stick has been created, copy the contents of `win11-usb` to the root of the folder (so that `OOBE.bat` is at the top level of your USB stick)
3. Edit `$GroupTag` in `Get-Autopilot-Hash.ps1` as appropriate. For student loan devices, this should be `StudentLoan`. If you're not sure what group tag to use, have a look in `Intune > Devices > Device Onboarding > Enrollment > Windows Autopilot > Devices` and see what Group Tags are currently in use
3. Plug in power, then boot from the USB stick. `autounattend.xml` will automatically install Windows using the Windows 11 Pro key. It will also default the region to English (Australian). ***BE CAREFUL, AS THE INSTALLATION STARTS AUTOMATICALLY AND WILL WIPE THE ENTIRE MACHINE!***
4. When Windows has rebooted to the OOBE screen, press `Shift+F10` (you might need to use `FN+Shift+F10`) and run `D:\oobe.bat`
5. Repeat steps 3 and 4 for each laptop you have.
6. `Autpilot.csv` can then be uploaded to Intune in the same place as mentioned in step 3
7. Once the import is successful, wait until you see the status change to `Assigned`.
8. Start the laptop again, connect / authenticate to the internet again, and the machine should automatically detect it's an Autopilot machine and set itself up.
9. Log in as a user to make sure everything is set up correctly.
