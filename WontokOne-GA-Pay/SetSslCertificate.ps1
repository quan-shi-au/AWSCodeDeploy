$siteName = 'Nop4'
$hostName = 'www.samlocal.com'
$certificateDnsName = '*.samlocal.com'

$MyCert = Get-ChildItem cert:\LocalMachine\MY -DnsName $certificateDnsName
if ($MyCert)
{
    Write-Host "$MyCert"
}else {
    Write-Host "Certificate doesn't exist - DNS Name $certificateDnsName"
}

# get the web binding of the site
$binding = Get-WebBinding -Name $siteName -Protocol "https"

if(!$binding)
{
    Write-Host "Create SSL binding"

    New-WebBinding -Name $siteName -IP "*" -Port 443 -Protocol https -HostHeader $hostName
    $binding = Get-WebBinding -Name $siteName -Protocol "https"

    # set the ssl certificate
     $binding.AddSslCertificate($MyCert.GetCertHashString(), "my")
    
} else {
    Write-Host "SSL Binding already exists"
}


