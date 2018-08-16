$AppPoolName="WontokAppPool"

# Stop the AppPool
if ((Get-WebAppPoolState $AppPoolName).Value -ne 'Stopped') {

    Write-Host "Shut Down App Pool - $AppPoolName..."
    
    Stop-WebAppPool -Name $AppPoolName

    if ((Get-WebAppPoolState $AppPoolName).Value -ne 'Stopped') {
        Start-Sleep -Seconds 1
    }

    Write-Host "$AppPoolName stopped."
}
else {
    Write-Host "$AppPoolName already stopped"
}

