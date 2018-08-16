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
$iisAppName = "WontokOne GA API"
$iisHostName = "ga-api.wontokone.com"
$directoryPath = "c:\inetpub\wwwroot\WontokOne_GA_API"
$IISApplicationName = "api"
$IISApplicationPath = "c:\inetpub\wwwroot\WontokOne_GA_API\api"

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
Get-WebSite -Name "recon" | Remove-WebSite -Confirm:$false -Verbose

#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
     #create the app pool
     $appPool = New-Item $iisAppPoolName
     $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion

}

#Assign user to AppPool
Set-ItemProperty IIS:\AppPools\WontokAppPool -name processModel -value @{userName="WontokAppPool";password="w0nt0k@123";identitytype=3}

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
if (Test-Path $iisAppName -pathType container)
{
    return
}

#create the site
#$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $directoryPath
$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $directoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName

#create default site
$iisDefaultApp = New-Item $iisDefaultAppName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $defaultDirectoryPath
$iisDefaultApp | Set-ItemProperty -Name "applicationPool" -Value $defaultAppPoolName

#assign ports 433
New-WebBinding -Name $iisAppName -IP "*" -Port 443 -Protocol https -HostHeader $iisHostName

#assign certificate
#Set-Location IIS:\SslBindings
#Get-ChildItem cert:\LocalMachine\MY | Where-Object {$_.Subject -match "CN=VM*"} | Select-Object -First 1 | New-Item 0.0.0.0!443 

#create API application
New-WebApplication $IISApplicationName -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISApplicationPath


#restart website
Stop-WebSite $iisAppName 
Start-WebSite $iisAppName

#iisreset
invoke-command -scriptblock {iisreset}
