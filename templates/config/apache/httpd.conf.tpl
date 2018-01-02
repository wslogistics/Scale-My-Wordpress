ServerRoot \"/etc/httpd\"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache

ServerName ${app_domain_name}
ServerAdmin admin@example.com

<Directory />
    AllowOverride none
    Require all denied
</Directory>

DocumentRoot \"${app_root}\"

<Directory \"/var/www\">
    AllowOverride None
    Require all granted
</Directory>

<Directory \"${app_root}\">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files \".ht*\">
    Require all denied
</Files>

ErrorLog \"logs/error_log\"

LogLevel warn

<IfModule log_config_module>
    LogFormat \"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\"\" combined
    LogFormat \"%h %l %u %t \\"%r\\" %>s %b\" common

    <IfModule logio_module>
      LogFormat \"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O\" combinedio
    </IfModule>

    #CustomLog \"logs/access_log\" common
    CustomLog \"logs/access_log\" combined
</IfModule>

<IfModule alias_module>
    ScriptAlias /cgi-bin/ \"/var/www/cgi-bin/\"
</IfModule>

<Directory \"/var/www/cgi-bin\">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>

EnableSendfile on

IncludeOptional conf.d/*.conf
