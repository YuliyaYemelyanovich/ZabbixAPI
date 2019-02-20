#!/bin/bash

if [ "$(systemctl list-units | grep mariadb)" == "" ]
then
yum install mariadb mariadb-server -y
/usr/bin/mysql_install_db --user=mysql
fi	

useradd zabbix -p $(openssl passwd 123456)
systemctl enable mariadb
systemctl start mariadb

if [ "$(mysql -uroot -e "show databases;" | grep zabbix)" == "" ]
then 
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to zabbix@localhost identified by '123456';"
fi

yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-server-mysql zabbix-web-mysql

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -p123456 zabbix

sed -i 's/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=123456/' /etc/zabbix/zabbix_server.conf



sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Minsk/; s/Alias \/zabbix \/usr\/share\/zabbix/#Alias \/zabbix \/usr\/share\/zabbix/' /etc/httpd/conf.d/zabbix.conf
sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/zabbix"/' /etc/httpd/conf/httpd.conf



yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-agent
sed -i 's/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/; s/# ListenPort=10050/ListenPort=10050/; s/# StartAgents=3/StartAgents=3/; s/# DebugLevel=3/DebugLevel=3/' /etc/zabbix/zabbix_agentd.conf

cat <<EOF > /etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = '123456';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Zabbix Server';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF

chown apache: /etc/zabbix/web/zabbix.conf.php
chmod 644 /etc/zabbix/web/zabbix.conf.php




systemctl enable httpd
systemctl start httpd
systemctl enable zabbix-agent
systemctl start zabbix-agent
systemctl enable zabbix-server
systemctl start zabbix-server



