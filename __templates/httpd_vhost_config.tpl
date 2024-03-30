# @SiteUrl@

<VirtualHost *:80>

    ServerAdmin webmaster@localhost
    DocumentRoot "@Site_DocRoot@"
    ServerName @SiteUrl@
    ServerAlias www.@SiteUrl@
    ErrorLog "/Users/gce/Sites/_ApacheLogs/@SiteUrl@-error.log"
    CustomLog "/Users/gce/Sites/_ApacheLogs/@SiteUrl@-access.log" common

    <Directory "@Site_DocRoot@">
        Options Indexes FollowSymLinks
        Require all granted
        AllowOverride All
    </Directory>

</VirtualHost>
