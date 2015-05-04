#!/bin/sh

if [ ! -f /var/lib/mysql/ibdata1 ]
then

    mysql_install_db

    /usr/bin/mysqld_safe &
    sleep 10s

    echo "INSTALL PLUGIN sphinx SONAME 'ha_sphinx.so'" | mysql
    echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

    killall mysqld
    sleep 10s
fi

#if [ -n "$SYNC_UID" ]; then
#    if [ $SYNC_UID -eq 1 ]
#    then
#        uid=`stat -c '%u' $DATA`
#        gid=`stat -c '%g' $DATA`
#
#        echo "Updating mysql ids to ($uid:$gid)"
#
#        if [ ! $uid -eq 0 ]
#        then
#            sed -i "s#^mysql:x:.*:.*:#mysql:x:$uid:$gid:#" /etc/passwd
#        fi
#
#        if [ ! $gid -eq 0 ]
#        then
#            sed -i "s#^mysql:x:.*:#mysql:x:$gid:#" /etc/group
#        fi
#
#        chown mysql /var/log/mysql
#    fi
#fi
