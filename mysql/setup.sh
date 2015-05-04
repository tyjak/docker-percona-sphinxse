#!/bin/sh
cp -a /build/mysql/my_docker.cnf /etc/mysql/conf.d/my_docker.cnf

# Configure nginx (docroot and front controller) on startup
cp -a /build/mysql/init.sh /etc/my_init.d/00_configure_mysql.sh
chmod +x /etc/my_init.d/00_configure_mysql.sh

# Configure nginx to start as a service
mkdir /etc/service/mysql
cp -a /build/mysql/runit.sh /etc/service/mysql/run
chmod +x /etc/service/mysql/run
