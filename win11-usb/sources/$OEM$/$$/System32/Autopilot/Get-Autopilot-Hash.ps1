# This script downloads the Get-WindowsAutoPilotInfo script and runs it
# Change the group tag to match your Autopilot profile
$GroupTag = "StudentLoan"
$Timezone = "AUS Eastern Standard Time"
$InternetAttempts = 5 # How many times to attempt to connect to the internet before giving up and dropping you to Edge for captive portal stuff
$SSID = "Lavalla BYOD" # SSID to connect to
$RestartTimeout = 10 # How long to wait until the computer shuts down
$UploadToMicrosoft = $True # If true, will automatically upload the hash to Microsoft. If false, will save to a local file instead
$TmpCSVFile = "D:\tmp.csv" # Where the interim hash will be saved (if $UploadToMicrosoft is false)
$AutopilotCSVFile = "D:\Autopilot.csv" # Where the final, ready to upload autopilot CSV will be saved (if $UploadToMicrosoft is false)

Try {
    . .\Autopilot\Credentials.ps1 # Load in our credentials from another file. They are "dot sourced" so they're essentially imported into this script. 
}
Catch {
    Write-Error "Autopilot\Credentials.ps1 not found! Make sure the file exists, and try again"
    Exit
}


# Looks for imported credentials to make sure the script will run properly. 
function Test-Credentials {

    $varsToTest = @(
        "TenantID",
        "AppID",
        "AppSecret"
    )

    $validVars = Get-Variable -Name $varsToTest -ErrorAction SilentlyContinue | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_.Value)
    }

    if ($validVars.Count -ne $varsToTest.Count) {
        Write-Host "One or more variables are missing. Make sure that Credentials.ps1 exists and that it contains valid TenantID, AppID and AppSecret"
    }

}

# Import the internet certificate, used to try and ensure a good connection to the internet
function Import-InternetCertificate {
    $CertPath = ".\Autopilot\Certificates\InternetCertificate.cer"
    $CertStoreLocation = "Cert:\LocalMachine\Root"

    Write-Host "Installing internet certificate.."
    Import-Certificate -FilePath $CertPath  -CertStoreLocation $CertStoreLocation -ErrorAction SilentlyContinue
}

function Import-Wifi {
    $XMLPath = ".\Autopilot\Wifi\wifi-byod.xml"
    Write-Host "Connecting to wifi.."
    netsh wlan add profile filename="$XMLPath"
    netsh wlan connect name="$SSID"
}

# Make the scripts directory. This is where the Get-WindowsAutoPilotInfo script gets downloaded to, and it needs to exist first
function New-ScriptsDirectory {
    $Path = "C:\Program Files\WindowsPowerShell\Scripts"

    if ((Test-Path -Path $Path) -eq $false) {
        Write-Host "Creating scripts directory.."
        New-Item -Path $Path -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
    }

    Set-Location -Path $Path
}

# NuGet contains the Autopilot script and dependencies, so it needs to be installed
function Install-NuGet {
    Write-Host "Installing Nuget package provider and Get-WindowsAutoPilotInfo script.."
    Install-PackageProvider -Name NuGet -Confirm:$false -Force:$true
}

# Install the Get-WindowsAutoPilotInfo script
function Install-AutoPilotInfoScript {
    Write-Host "Installing Get-WindowsAutoPilotInfo script.."
    Install-Script -Name Get-WindowsAutoPilotInfo -Confirm:$false -Force:$true    
}

# Test the internet connection to make sure we can download the script we need
function Test-InternetConnection {
    param ($Uri = "http://en.wikipedia.org", $SuccessString = "<title>Wikipedia", $Tries = $InternetAttempts)

    for ($Tries = 1; $Tries -le $InternetAttempts; $tries++) {
        # Assume the internet test failed unless we're told otherwise
        $Result = $false 

        Write-Host "Checking internet connection. Attempt $tries of $InternetAttempts"
        # Get the contents of the webpage
        $page = Invoke-WebRequest -Uri $Uri -UseBasicParsing

        # Look for $SuccessString in the resulting HTML. If we see this, we know the website has loaded successfully
        if ($page.Content.Contains($SuccessString)) {
            $Result = $true 
            Break
        }

        Start-Sleep -Seconds 2
    }

    if ($Result -eq $true) {
        return $true
    }

    # If we can't work out if the internet is connected, launch the browser as a fallback
    Write-Warning "Unable to determine if connected to the internet. Launching browser. Confirm the internet is working, then close the browser to continue"
    Start-Process $Uri -Wait


    Return $false
}

# Get the hardware hash and upload it to Microsoft using the credentials stored in Credentials.ps1
function Get-Hash {
    param($TempFile = "D:\tmp.csv", $FinalFile = "D:\Autopilot.csv", $Upload = $True)
    
    if($Upload -eq $True) {
        Write-Host "Retrieving hash and uploading to Microsoft.."
        & .\Get-WindowsAutopilotInfo.ps1 -GroupTag $GroupTag -ComputerName $env:computername -Online -Assign -TenantId $TenantID -AppId $AppID -AppSecret $AppSecret
    } else {
        Write-Host "Retrieving host and saving to D:\Autopilot.csv.."
        & .\Get-WindowsAutopilotInfo.ps1 -GroupTag $GroupTag -ComputerName $env:computername -OutputFile $TempFile -Append
        # Convert the file into ASCII, as the Intune portal has troubles with the file otherwise
        Get-Content -Path $TempFile | Out-File -FilePath $FinalFile -Encoding ascii
    }
        
}

# Set the timezone to avoid "Your time is incorrectly set!" errors
function Set-CurrentTime {
    Write-Host "Setting Timezone.."
    Set-Timezone -Name $Timezone
    Start-Service w32time # Sync won't work if NTP isn't enabled
    W32tm /resync /force # Force a time sync with NTP

    Write-Host "Time is now $(Get-Date)"
}

# Removes this script and the additional files
function Remove-Temporary-Files {
    # A list of files to cleanup. This is to ensure we don't accidentally leave sensitive files behind
    $WindowsPath = "C:\Windows\System32"

    $FilesToDelete = @(
        "$WindowsPath\Autopilot",
        "$WindowsPath\Lavalla-OOBE.bat"
    )
    
    Remove-Item -Path $FilesToDelete -Recurse -Force # Delete the files
    $WasDeleted = Test-Path -Path $FilesToDelete # Make sure the files are actually deleted
    
    if (@($WasDeleted -ne $false).Count -gt 0) {
        Write-Error -Message "Unable to clean up files. Please make sure the following files are deleted: " + $FilesToDelete
    }

}

Test-Credentials # Make sure we've got credentials for adding to Autopilot automatically

Try {
    # Import the internet certificate
    Import-InternetCertificate
}
Catch {
    Write-Error "Unable to import internet certificate: $_"
}

Try {
    # Add the wifi credentials
    Import-Wifi

    Write-Host "If you need to authenticate to a captive portal, please do so now, then press Enter" -ForegroundColor green -NoNewline
    Read-Host

    # Make sure we've got an internet connection. This will loop until it detects a connection
    $ConnectionSuccess = Test-InternetConnection

    if ($ConnectionSuccess -eq $false) {
        Exit
    }

    Write-Host "Internet connection established." -ForegroundColor green
}
Catch {
    Write-Error "Unable to connect to wifi: $_"
}

Try {
    # Create the Scripts directory so we can download the AutoPilotInfo script to it
    New-ScriptsDirectory
}
Catch {
    Write-Error "Unable to change to Scripts directory: $_"
    Exit
}

# Switch on PSRemoting which is required for the Autopilot script
Write-Host "Enabling PSRemoting"
Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Fix the current time.
Set-CurrentTime

Try {
    # Install the NuGet provider and AutoPilotInfo script
    Install-NuGet
    Install-AutoPilotInfoScript
}
Catch {
    Write-Error "Unable to install Nuget or Autopilot script: $_"
    Exit
}

Write-Host "Getting Autopilot hash.."
Try {
    Get-Hash -TempFile $TmpCSVFile -FinalFile $AutopilotCSVFile -Upload $UploadToMicrosoft
}
Catch {
    Write-Error "Unable to get Autopilot information: $_"
    Exit
}

Try {
    Remove-Temporary-Files
}
Catch {
    Write-Error "Unable to delete temporary scripts. Please delete $PSCommandPath and the Autopilot folder from C:\Windows\System32"
    Exit
}

Write-Host "Restarting laptop in $RestartTimeout seconds. Press Ctrl+C to stop" -ForegroundColor yellow
Start-Sleep -Seconds $RestartTimeout
Restart-Computer