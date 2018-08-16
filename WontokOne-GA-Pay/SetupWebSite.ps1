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

$GAPayAppPoolName = "WontokAppPool"
$iisAppPoolDotNetVersion = "v4.0"
$GAPayWebSiteName = "WontokOne GA PAY"
$iisHostName = "ga-pay.wontokone.com"
$GAPayWebFilePath = "c:\inetpub\wwwroot\WontokOne_GA_PAY"
$GaApiApplicationName = "api"
$GaApiApplicationPath = "c:\inetpub\wwwroot\WontokOne_GA_PAY\api"

#default website settings
$ReconAppName = "recon"
$ReconWebFilePath = "c:\inetpub\wwwroot\recon"
$ReconIndexFile = "c:\inetpub\wwwroot\recon\index.html"
$ReconAppPoolName = "ReconAppPool"

# Create folder and files
New-Item -ItemType Directory -Force -Path $GAPayWebFilePath
New-Item -ItemType Directory -Force -Path $ReconWebFilePath
New-Item -ItemType File -Force -Path $ReconIndexFile

#navigate to the app pools root
Set-Location IIS:\AppPools\

#remove default Website if exists
Get-WebSite -Name "Default Web Site" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "Default Website" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "recon" | Remove-WebSite -Confirm:$false -Verbose

#check if the app pool exists
if (!(Test-Path $GAPayAppPoolName -pathType container))
{
    Write-Output "Create AppPool $GAPayAppPoolName"
     #create the app pool
     $appPool = New-Item $GAPayAppPoolName
     $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
} else {
    Write-Output "AppPool $GAPayAppPoolName already exists."
}

#Assign user to AppPool
Set-ItemProperty IIS:\AppPools\WontokAppPool -name processModel -value @{userName="WontokAppPool";password="w0nt0k@123";identitytype=3}

#create default website's app pool
if (!(Test-Path $ReconAppPoolName -pathType container))
{
     #create the app pool
     $appDefPool = New-Item $ReconAppPoolName
     $appDefPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#navigate to the sites root
Set-Location IIS:\Sites\

#check if the site exists
if (Test-Path $GAPayWebSiteName -pathType container)
{
	#restart website
    Write-Output "restart $GaApiApplicationName"
	Stop-WebSite $GaApiApplicationName
	Start-WebSite $GaApiApplicationName
	
    Write-Output "restart $GAPayWebSiteName"
	Stop-WebSite $GAPayWebSiteName 
	Start-WebSite $GAPayWebSiteName
	
    Write-Output "Sites already exist. exit."
	
    return
} else {
    Write-Output "Create Web Site $GAPayWebSiteName"
}

#create the site
#$iisApp = New-Item $GAPayWebSiteName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $GAPayWebFilePath
$iisApp = New-Item $GAPayWebSiteName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $GAPayWebFilePath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $GAPayAppPoolName

#create default site
$iisDefaultApp = New-Item $ReconAppName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $ReconWebFilePath
$iisDefaultApp | Set-ItemProperty -Name "applicationPool" -Value $ReconAppPoolName

#assign ports 433
New-WebBinding -Name $GAPayWebSiteName -IP "*" -Port 443 -Protocol https -HostHeader $iisHostName

#assign certificate
#Set-Location IIS:\SslBindings
#Get-ChildItem cert:\LocalMachine\MY | Where-Object {$_.Subject -match "CN=VM*"} | Select-Object -First 1 | New-Item 0.0.0.0!443 

#create API application
New-WebApplication $GaApiApplicationName -Site $GAPayWebSiteName -ApplicationPool $GAPayAppPoolName -PhysicalPath $GaApiApplicationPath



#iisreset
invoke-command -scriptblock {iisreset}
