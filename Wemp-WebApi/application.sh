rm -rf /var/www_release
rm -rf /var/afteramp
rm -rf /var/www_release?
systemctl stop wempapi.service
kill $(ps aux | grep 'Wontok.Wemp.WebApi.dll' | awk '{print $2}')
mkdir /var/www_release
chmod -R a+rX /var/www_release
dotnet restore /var/www/wemp_app/Wontok.Wemp.WebApi/
dotnet publish /var/www/wemp_app/Wontok.Wemp.WebApi/Wontok.Wemp.WebApi.csproj -c Release -o /var/www_release
cp -a /var/www/wemp_app/Wontok.Wemp.WebApi/Edm  /var/www_release/Edm
chmod -R a+rX -u www-data /var/www_release
cp -a /var/www_release/appsettings.json  /home/ubuntu/appsettings.json
cp -a  /var/www/wemp_app/Wontok.Wemp.WebApi/health.html /var/www_release/health.html
cp -a  /var/www/wemp_app/Wontok.Wemp.WebApi/TGK/  /var/www_release/TGK/