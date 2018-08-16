if ($PSHOME -like "*SysWOW64*")
{
  Write-Warning "Restarting StartAppPool.ps1 under 64-bit Windows PowerShell."

  # Restart this script under 64-bit Windows PowerShell.
  #   (\SysNative\ redirects to \System32\ for 64-bit mode)

  & (Join-Path ($PSHOME -replace "SysWOW64", "SysNative") powershell.exe) -File `
    (Join-Path $PSScriptRoot $MyInvocation.MyCommand) @args

  # Exit 32-bit script.

  Exit $LastExitCode
}

Import-Module WebAdministration

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
