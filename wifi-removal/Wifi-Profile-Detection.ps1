# This script detects whether the target device has the mentioned wifi profile set up.
# Edit $Profile to match the name of the network you wish to remove

$ProfileName = "Lavalla IoT"

# =======================================================================================

Try {
    # Run netsh wlan show profiles to get all the wifi profiles installed on the machine 
    $FoundProfiles = netsh wlan show profiles
}
Catch {
    # If the detection fails, run the remediation script anyway, as there's no harm in doing so
    Write-Host "Detection failed, running remediation anyway"
    Exit 1    
}

# If the machine has $Profile installed..
If ($FoundProfiles -Match $ProfileName) {
    # ..then Exit 1, which will start the remediation script
    Write-Host "Profile '$Profile' detected, running remediation script.."
    Exit 1
}
Else {
    Write-Host "Profile '$Profile' not found, exiting"
    Exit 0 
}