# Are you running in 32-bit mode?
#   (\SysWOW64\ = 32-bit mode)

if ($PSHOME -like "*SysWOW64*")
{
  Write-Warning "Restarting this script under 64-bit Windows PowerShell."

  # Restart this script under 64-bit Windows PowerShell.
  #   (\SysNative\ redirects to \System32\ for 64-bit mode)

  & (Join-Path ($PSHOME -replace "SysWOW64", "SysNative") powershell.exe) -File `
    (Join-Path $PSScriptRoot $MyInvocation.MyCommand) @args

  # Exit 32-bit script.

  Exit $LastExitCode
}

Import-Module WebAdministration

$iisAppPoolName = "WontokAppPool"
$iisAppName = "WontokOne GA Promo"
$IISApplicationName = "api"
$IISApplicationPath = "c:\inetpub\wwwroot\idSafe\api"

$apiApplication = Get-WebApplication -Site $iisAppName -Name $IISApplicationName
if ($apiApplication)
{
  Write-Host "Application - $IISApplicationName already exists."
} else {
  Write-Host "Create Application - $IISApplicationName..."
	New-WebApplication $IISApplicationName -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISApplicationPath
}

invoke-command -scriptblock {iisreset}
