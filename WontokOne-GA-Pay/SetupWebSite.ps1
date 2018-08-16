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
$certificateDnsName = '*.wontokone.com'
$GAPayWebFilePath = "c:\inetpub\wwwroot\WontokOne_GA_PAY"
$GaApiApplicationName = "api"
$GaApiApplicationPath = "c:\inetpub\wwwroot\WontokOne_GA_PAY\api"

#default website settings
$ReconAppName = "recon"
$ReconWebFilePath = "c:\inetpub\wwwroot\recon"
$ReconIndexFile = "c:\inetpub\wwwroot\recon\index.html"
$ReconAppPoolName = "ReconAppPool"

#check if the site exists
Set-Location IIS:\Sites\

if (Test-Path $GAPayWebSiteName -pathType container)
{
    Write-Output "$GAPayWebSiteName Sites already exist. exit."
    return
} else {
    Write-Output "Create Web Site $GAPayWebSiteName"
}

# Create folder and files
New-Item -ItemType Directory -Force -Path $ReconWebFilePath
New-Item -ItemType File -Force -Path $ReconIndexFile

#navigate to the app pools root
Set-Location IIS:\AppPools\

#check if the GA-Pay app pool exists
if (!(Test-Path $GAPayAppPoolName -pathType container))
{
    Write-Output "Create AppPool $GAPayAppPoolName"
    $appPool = New-Item $GAPayAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
    Set-ItemProperty IIS:\AppPools\WontokAppPool -name processModel -value @{userName="WontokAppPool";password="w0nt0k@123";identitytype=3}
} else {
    Write-Output "AppPool $GAPayAppPoolName already exists."
}

#create Recon website's app pool
if (!(Test-Path $ReconAppPoolName -pathType container))
{
     #create the app pool
     $appDefPool = New-Item $ReconAppPoolName
     $appDefPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#navigate to the sites root
Set-Location IIS:\Sites\

#create GA-Pay site
$iisApp = New-Item $GAPayWebSiteName -bindings @{protocol="http";bindingInformation=":80:" + $iisHostName} -physicalPath $GAPayWebFilePath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $GAPayAppPoolName

#create Recon site
$iisDefaultApp = New-Item $ReconAppName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $ReconWebFilePath
$iisDefaultApp | Set-ItemProperty -Name "applicationPool" -Value $ReconAppPoolName

#assign ports 433
$MyCert = Get-ChildItem cert:\LocalMachine\MY -DnsName $certificateDnsName

if ($MyCert)
{
    Write-Host "$MyCert"
}else {
    Write-Host "Certificate doesn't exist - DNS Name $certificateDnsName"
}

# get the web binding of the site
$binding = Get-WebBinding -Name $GAPayWebSiteName -Protocol "https"

if(!$binding)
{
    Write-Host "Create SSL binding"

    New-WebBinding -Name $GAPayWebSiteName -IP "*" -Port 443 -Protocol https -HostHeader $hostName
    $binding = Get-WebBinding -Name $GAPayWebSiteName -Protocol "https"

    # set the ssl certificate
     $binding.AddSslCertificate($MyCert.GetCertHashString(), "my")
    
} else {
    Write-Host "SSL Binding already exists"
}

#create API application
New-WebApplication $GaApiApplicationName -Site $GAPayWebSiteName -ApplicationPool $GAPayAppPoolName -PhysicalPath $GaApiApplicationPath

#iisreset
invoke-command -scriptblock {iisreset}
