#nginx redo
sed -i -e 's!#CORS-ADDED BSAYEJ!if ($request_method ~* "(GET|POST|DELETE)") { add_header "Access-Control-Allow-Origin"  * always;}!g' /etc/nginx/conf.d/default.conf
sed -i -e 's!if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri$http_x_forwarded_proto;}!!g' /etc/nginx/conf.d/default.conf
sed -i -e 's!if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri;}!!g' /etc/nginx/conf.d/default.conf
sed -i -e 's!enterpriseapi.wontok.net;!enterpriseapi.wontok.net; \n if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri;}\n!g' /etc/nginx/conf.d/default.conf
systemctl reload nginx.service
#daemon service
rm -rf /etc/systemd/system/wempapi.service
touch /etc/systemd/system/wempapi.service
echo -e  " [Unit]\n Description=WEMP API  .NET Core App\n [Service] \n WorkingDirectory=/var/www_release \n ExecStart=/usr/bin/dotnet /var/www_release/Wontok.Wemp.WebApi.dll \n Restart=always \n RestartSec=10 \n SyslogIdentifier=dotnet-wempapi \n User=www-data \n Environment=ASPNETCORE_ENVIRONMENT=Production \n [Install]\n  WantedBy=multi-user.target" >  /etc/systemd/system/wempapi.service
chown -R www-data:www-data /var/www_release
sudo chmod 755 -R  /var/www_release
systemctl enable wempapi.service
systemctl daemon-reload
systemctl stop wempapi.service
systemctl start wempapi.service
