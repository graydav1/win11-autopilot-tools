$ProfileName = "Lavalla IoT"

# Remove IoT Profile
netsh wlan delete profile name="$ProfileName"

# Pause for 5 seconds to allow removal to complete
Start-Sleep -Milliseconds 5000

$FoundProfiles = netsh wlan show profiles

#Check if the profile has gone and exit 0
If ($FoundProfiles -Match $ProfileName) {
    Write-Host "Profile is still in the system!"
    Exit 1
}
Else {
    Write-Host "Profile has been removed"
    Exit 0
}