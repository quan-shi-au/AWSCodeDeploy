$AppPoolName="WontokAppPool"

# Start AppPool
if ((Get-WebAppPoolState $AppPoolName).Value -ne 'Started') {
    Start-WebAppPool -Name $AppPoolName

    while ((Get-WebAppPoolState $AppPoolName).Value -ne 'Started') {
        Start-Sleep -Seconds 1
    }
    Write-Host "AppPool $AppPoolName started."
}
else {
    Write-Host "AppPool $AppPoolName already started"
}
