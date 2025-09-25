# This script downloads the Get-WindowsAutoPilotInfo script and runs it
# Change the group tag to match your Autopilot profile
$GroupTag = "StudentLoanTPX13Y"
$Timezone = "AUS Eastern Standard Time"

Write-Host "Creating scripts directory.."
New-Item -Path "C:\Program Files\WindowsPowerShell\Scripts" -ItemType "Directory" | Out-Null
Try {
    Set-Location -Path "C:\Program Files\WindowsPowerShell\Scripts"
}
Catch {
    Write-Error "Unable to change to Scripts directory"
    Exit
}

Write-Host "Setting Timezone.."
Set-Timezone -Name $Timezone

Write-Host "Enabling PSRemoting"
Enable-PSRemoting -SkipNetworkProfileCheck -Force

Try {
    Write-Host "Installing Nuget package provider and Get-WindowsAutoPilotInfo script.."
    Install-PackageProvider -Name NuGet -Confirm:$false -Force:$true
    Install-Script -Name Get-WindowsAutoPilotInfo -Confirm:$false -Force:$true    
}
Catch {
    Write-Error "Unable to install Nuget or Autopilot script"
    Exit
}

Write-Host "Getting Autopilot hash and saving to D:\autopilot.csv"
& .\Get-WindowsAutopilotInfo.ps1 -GroupTag $GroupTag -ComputerName $env:computername -OutputFile d:\tmp.csv -Append
Get-Content -Path D:\tmp.csv | Out-File -FilePath D:\Autopilot.csv -Encoding ascii

Write-Host "Shutting down in 30 seconds. Press Ctrl+C to stop" -ForegroundColor yellow
Start-Sleep -Seconds 30
Stop-Computer