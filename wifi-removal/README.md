# Wifi Profile Removal Remediation Script
This script removes a wifi profile from a target machine. This is useful if you require a different wifi network for something (e.g. Kiosk mode) but don't want that profile applied when the device is no longer set to be in Kiosk mode

## Usage
1. Open the [Scripts and Remediations page](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/overview) on Intune (Devices > Scripts and Remediations)
2. Create a new script
3. Give it a meaningful name and description (see Configuration policies to see how other similar things are named)
4. Edit the detection (`Wifi-Profile-Detection.ps1`) and removal (`Wifi-Profile-Remediation.ps1`) scripts to specify your network
5. Upload the Detection and Remediation scripts as instructed
6. Leave the three toggleboxes set to "No"
7. Assign the script to the correct dynamic group. 
8. Monitor the rollout. 

## Tips
* Make sure that the target devices have a backup wifi network they can connect to, otherwise you'll need to plug each device in to ethernet if you wish to make changes