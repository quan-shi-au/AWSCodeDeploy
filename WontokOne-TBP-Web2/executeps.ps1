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

#make sure the local is correct
$varlocale = Get-WinSystemLocale;
if($varlocale -ne "en-AU")
{
	Set-WinSystemLocale  en-AU
}

#Set-ExecutionPolicy RemoteSigned
Import-Module WebAdministration
$iisAppPoolName = "WontokAppPool"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "Wontok TBP"
$iisHostName = "protectsw.telstra.com.au"
$directoryPath = "c:\inetpub\wwwroot\Wontok.TSafe.Web"
$IISApplicationName = "Admin"
$IISApplicationPath = "c:\inetpub\wwwroot\Wontok.TSafe.Web\MvcApplication1"
$IISFBApplicationName = "Feedback"
$IISFBApplicationPath = "c:\inetpub\wwwroot\Wontok.TSafe.Web\Wontok.TSafe.Feedback"

#default website settings
$iisDefaultAppName = "recon"
$defaultDirectoryPath = "c:\inetpub\wwwroot\recon"
$defaultDirectoryIndexFile = "c:\inetpub\wwwroot\recon\index.html"
$defaultAppPoolName = "ReconAppPool"


#create application directoryPath
New-Item -ItemType Directory -Force -Path $directoryPath

#create default application directoryPath
New-Item -ItemType Directory -Force -Path $defaultDirectoryPath
#create default application directoryPath - create index file
New-Item -ItemType File -Force -Path $defaultDirectoryIndexFile

#navigate to the app pools root
cd IIS:\AppPools\

#remove default Website if exists
Get-WebSite -Name "Default Web Site" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "Default Website" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "default" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "Wontok TBP" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "recon" | Remove-WebSite -Confirm:$false -Verbose

# #check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
     #create the app pool
     $appPool = New-Item $iisAppPoolName
     $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#create default website's app pool
if (!(Test-Path $defaultAppPoolName -pathType container))
{
     #create the app pool
     $appDefPool = New-Item $defaultAppPoolName
     $appDefPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
#if (Test-Path $iisAppName -pathType container)
#{
#    return
#}

#create the site
$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $directoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName

#create default site
$iisDefaultApp = New-Item $iisDefaultAppName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $defaultDirectoryPath
$iisDefaultApp | Set-ItemProperty -Name "applicationPool" -Value $defaultAppPoolName

#assign ports 433
#New-WebBinding -Name $iisAppName -IP "*" -Port 443 -Protocol https -HostHeader $iisHostName

#assign certificate
#Set-Location IIS:\SslBindings
#Get-ChildItem cert:\LocalMachine\MY | Where-Object {$_.Subject -match "CN=VM*"} | Select-Object -First 1 | New-Item 0.0.0.0!443 

#create Admin applications
New-WebApplication $IISApplicationName -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISApplicationPath

#create Feedback applications
New-WebApplication $IISFBApplicationName -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISFBApplicationPath


#restart website
#Stop-WebSite $iisAppName 
#Start-WebSite $iisAppName

#restart default website
#Stop-WebSite $iisDefaultAppName 
#Start-WebSite $iisDefaultAppName

Start-WebSite -Name "Wontok TBP"

#iisreset
invoke-command -scriptblock {iisreset}
