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
$iisAppName = "TBP Download"
$iisHostName = "dl.protectsw.telstra.com.au"
$directoryPath = "C:\inetpub\wwwroot\dl.protectsw.telstra.com.au"
#$IISApplication1Name = "App1"
#$IISApplication1Path = "C:\CertPath"



#create application directoryPath
New-Item -ItemType Directory -Force -Path $directoryPath
#New-Item -ItemType Directory -Force -Path "C:\testpath"

#navigate to the app pools root
cd IIS:\AppPools\

#remove default Website if exists
Get-WebSite -Name "Default Web Site" | Remove-WebSite -Confirm:$false -Verbose
Get-WebSite -Name "Default Website" | Remove-WebSite -Confirm:$false -Verbose

# #check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
     #create the app pool
     $appPool = New-Item $iisAppPoolName
     $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
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
$iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $directoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName

#assign ports 433
#New-WebBinding -Name $iisAppName -IP "*" -Port 443 -Protocol https -HostHeader $iisHostName

#assign certificate
#Set-Location IIS:\SslBindings
#Get-ChildItem cert:\LocalMachine\MY | Where-Object {$_.Subject -match "CN=VM*"} | Select-Object -First 1 | New-Item 0.0.0.0!443 

#create applications
#New-WebApplication $IISApplication1Name -Site $iisAppName -ApplicationPool $iisAppPoolName -PhysicalPath $IISApplication1Path


#restart website
Stop-WebSite $iisAppName 
Start-WebSite $iisAppName

#iisreset
invoke-command -scriptblock {iisreset}
