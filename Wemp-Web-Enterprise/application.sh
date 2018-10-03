systemctl stop nginx
chmod -R a+rX /var/www/wempapp
sed -i -e 's!if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri$http_x_forwarded_proto;}!!g' /etc/nginx/conf.d/default.conf
sed -i -e 's!if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri;}!!g' /etc/nginx/conf.d/default.conf
sed -i -e 's!enterprise.wontok.net;!enterprise.wontok.net; \n if ($http_x_forwarded_proto = "http") { return 301 https://$server_name$request_uri;}\n!g' /etc/nginx/conf.d/default.conf
systemctl start nginx
