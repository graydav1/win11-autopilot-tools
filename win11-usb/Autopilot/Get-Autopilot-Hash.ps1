# This script downloads the Get-WindowsAutoPilotInfo script and runs it
# Change the group tag to match your Autopilot profile
$GroupTag = "StudentLoanTPX13Y"
$Timezone = "AUS Eastern Standard Time"
$InternetAttempts = 10 # How many times to attempt to connect to the internet before giving up and dropping you to Edge for captive portal stuff

# Import the internet certificate, used to try and ensure a good connection to the internet
function Import-InternetCertificate {
    $CertPath = ".\Autopilot\InternetCertificate.cer"
    $CertStoreLocation = "Cert:\LocalMachine\Root"

    Write-Host "Installing internet certificate.."
    Import-Certificate -FilePath $CertPath  -CertStoreLocation $CertStoreLocation -ErrorAction SilentlyContinue
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
    param ($Uri = "http://neverssl.com", $SuccessString = "<title>NeverSSL")

    for ($tries = 1; $tries -le $InternetAttempts; $tries++) {
        $Result = $false 

        Write-Host "Checking internet connection. Attempt $tries of 10"
        # Get the contents of the webpage
        $page = Invoke-WebRequest -Uri $Uri -UseBasicParsing

        # Look for "<title>NeverSSL". If we see this, we know the website has loaded successfully
        if ($page.Content.Contains($SuccessString)) {
            $Result = $true 
            Break
        }

        Start-Sleep -Seconds 2
    }

    if($Result -eq $true) {
        return $true
    }

    Start-Process $Uri -Wait

    Return $false
}

function Get-Hash {
    param($TempFile = "D:\tmp.csv", $FinalFile = "D:\Autopilot.csv")
    # Run the AutopilotInfo script with our group tag and computer name. Save the file to a temporary file
    & .\Get-WindowsAutopilotInfo.ps1 -GroupTag $GroupTag -ComputerName $env:computername -OutputFile $TempFile -Append
    # Convert the file into ASCII 
    Get-Content -Path D:\tmp.csv | Out-File -FilePath $FinalFile -Encoding ascii
}

# Set the timezone to avoid "Your time is incorrectly set!" errors
function Set-CurrentTime {
    Write-Host "Setting Timezone.."
    Set-Timezone -Name $Timezone
    Start-Service w32time # Sync won't work if NTP isn't enabled
    W32tm /resync /force # Force a time sync with NTP
}


Try {
    # Import the internet certificate
    Import-InternetCertificate
}
Catch {
    Write-Error "Unable to import internet certificate: $_"
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

# Make sure we've got an internet connection. This will loop until it detects a connection
$ConnectionSuccess = Test-InternetConnection

if($ConnectionSuccess -eq $false) {
    Exit
}

Write-Host "Internet connection established. Downloading requirements.."

Try {
    # Install the NuGet provider and AutoPilotInfo script
    Install-NuGet
    Install-AutoPilotInfoScript
}
Catch {
    Write-Error "Unable to install Nuget or Autopilot script: $_"
    Exit
}

Write-Host "Getting Autopilot hash and saving to D:\autopilot.csv"
Try {
    Get-Hash
}
Catch {
    Write-Error "Unable to get Autopilot information: $_"
}

Write-Host "Shutting down in 30 seconds. Press Ctrl+C to stop" -ForegroundColor yellow
Start-Sleep -Seconds 30
Stop-Computer