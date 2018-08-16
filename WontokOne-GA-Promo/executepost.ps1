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

#Set-ExecutionPolicy RemoteSigned
Import-Module WebAdministration
$iisAppPoolName = "WontokAppPool"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "WontokOne GA Promo"
$iisHostName = "ga.wontokone.com"
$directoryPath = "c:\inetpub\wwwroot\WontokOne_GA_Promo"
$IISApplicationName = "api"
$IISApplicationPath = "c:\inetpub\wwwroot\WontokOne_GA_Promo\api"
 

#navigate to the sites root
cd IIS:\Sites\

#create API applications
New-WebApplication $IISApplicationName -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISApplicationPath



#iisreset
 invoke-command -scriptblock {iisreset}
