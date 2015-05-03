FROM ubuntu:14.04
MAINTAINER David Foucner <dev@tyjak.net>
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
RUN echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
RUN echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
WORKDIR /usr/local/src
ADD http://sphinxsearch.com/files/sphinx-2.2.9-release.tar.gz sphinx-2.2.9-release.tar.gz
RUN apt-get update && apt-get install -y \
    dpkg-dev\
    systemtap-sdt-dev\
    percona-server-server-5.5\
    percona-server-client-5.5 &&\
    apt-get source percona-server-server-5.5 &&\
    apt-get build-dep -s percona-server-server-5.5 | grep "Inst" | cut -d" " -f2 | sed 's/$/ /' | tr -d '\n' > percona-build.dep &&\
    apt-get build-dep -y percona-server-server-5.5 &&\
    tar -xzvf sphinx-2.2.9-release.tar.gz &&\
    mkdir percona-server-5.5-5.5.42-37.1/storage/sphinx/ &&\
    cp sphinx-2.2.9-release/mysqlse/* percona-server-5.5-5.5.42-37.1/storage/sphinx/ &&\
    cd percona-server-5.5-5.5.42-37.1 && sh BUILD/autorun.sh &&\
    ./configure --with-sphinx-storage-engine &&\
    cd storage/sphinx/ && make &&\
    cp ha_sphinx.so /usr/lib/mysql/plugin &&\
    cd /usr/local/src && cat percona-build.dep | xargs apt-get -y remove && rm -rf * &&\
    apt-get remove -y dpkg-dev systemtap-sdt-dev &&\
    apt-get autoremove -y 
EXPOSE 3306
COPY docker.cnf /etc/mysql/conf.d/
RUN service mysql start &&\
    echo "INSTALL PLUGIN sphinx SONAME 'ha_sphinx.so';\
          GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES;" \
    | mysql -uroot -h localhost
ENTRYPOINT ["/usr/bin/mysqld_safe"]
#CMD /usr/bin/mysqld_safe
#RUN mysqladmin --silent --wait=30 ping || exit 1 && echo "INSTALL PLUGIN sphinx SONAME 'ha_sphinx.so';" | mysql -uroot -h localhost

