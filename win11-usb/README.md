## win11-usb
This folder contains scripts that help you install Windows and get the autopilot hardware hash

### Usage
1. Create a Windows 11 installation USB using the [Media Creation Tool](https://support.microsoft.com/en-au/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d)
2. When the USB stick has been created, copy the contents of `win11-usb` to the root of the folder (so that `autounattend.xml` is at the top level of your USB stick)
3. Create the file `Credentials.ps1` in `sources\$OEM$\$$\System32\Autopilot` and set the contents to this, replacing `xxxxxx` with actual values. If you need to set this up again, see [this link](https://oofhours.com/2025/04/18/automatically-registering-autopilot-devices-with-intune/):
```powershell
$TenantID = "xxxxxx"
$AppID = "xxxxxx"
$AppSecret = "xxxxxx"
```
4. Edit `sources\$OEM$\$$\System32\Autopilot\Wifi\wifi-byod.xml` if you need to change the wifi network
5. Copy `InternetCertificate.cer` into `sources\$OEM$\$$\System32\Autopilot\Certificates`
6. Edit `$GroupTag` in `Get-Autopilot-Hash.ps1` as appropriate. For student loan devices, this should be `StudentLoan`. If you're not sure what group tag to use, have a look in `Intune > Devices > Device Onboarding > Enrollment > Windows Autopilot > Devices` and see what Group Tags are currently in use
7. Plug in power, then boot from the USB stick. `autounattend.xml` will automatically install Windows using the Windows 11 Pro key. It will also default the region to English (Australian). ***BE CAREFUL, AS THE INSTALLATION STARTS AUTOMATICALLY AND WILL WIPE THE ENTIRE MACHINE!***
8. When Windows has rebooted to the OOBE screen, press `Shift+F10` (you might need to use `FN+Shift+F10`) and run `Lavalla-oobe.bat`
9. Authenticate to the firewall if necessary. The script will obtain the hardware hash and upload it for you. The machine will then reboot and the rest of the OOBE will run
10. When you see the login screen, log in as a user (e.g. `pat`) and ensure things are working as they should
