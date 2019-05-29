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

$safeBrowserAppPoolName = "WontokSafeBrowser"
$iisAppPoolDotNetVersion = "v4.0"
$safeBrowserWebSiteName = "SafeBrowser"
$safeBrowserHostName = "safebrowser.safecentral.com"
$safeBrowserDirectoryPath = "c:\inetpub\wwwroot\AolWeb\SafeBrowser"

#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (!(Test-Path $safeBrowserAppPoolName -pathType container))
{
     #create the app pool
     $appPool = New-Item $safeBrowserAppPoolName
     $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion

}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $safeBrowserWebSiteName -pathType container)
{
    return
}

#create webapplication site bindings
$iisAppName_bindings = @(
		@{protocol="http";bindingInformation=":80:" + $safeBrowserHostName},
		@{protocol="http";bindingInformation=":88:"}
		)
$iisApp = New-Item $safeBrowserWebSiteName -bindings $iisAppName_bindings -physicalPath $safeBrowserDirectoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $safeBrowserAppPoolName

# Set "Enable Parent Paths"
Set-WebConfigurationProperty -PSPath MACHINE/WEBROOT/APPHOST -Location $safeBrowserWebSiteName -Filter system.webServer/asp -Name enableParentPaths -Value $true

