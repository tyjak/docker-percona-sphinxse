FROM ubuntu:14.04
MAINTAINER David Foucner <dev@tyjak.net>
LABEL Description="Last percona 5.5 with last sphinx storage engine plugin"
ENV PERCONA_VERSION=5.5 SPHINX_VERSION=2.2.9
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A &&\
    echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list &&\
    echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
WORKDIR /usr/local/src
ADD http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-release.tar.gz sphinx-${SPHINX_VERSION}-release.tar.gz
RUN apt-get update && apt-get install -y \
    dpkg-dev\
    systemtap-sdt-dev\
    percona-server-server-${PERCONA_VERSION}\
    percona-server-client-${PERCONA_VERSION}\
    percona-xtrabackup &&\
    apt-get source percona-server-server-${PERCONA_VERSION} &&\
    apt-get build-dep -s percona-server-server-${PERCONA_VERSION} | grep "Inst" | cut -d" " -f2 | sed 's/$/ /' | tr -d '\n' > percona-build.dep &&\
    apt-get build-dep -y percona-server-server-${PERCONA_VERSION} &&\
    tar -xzvf sphinx-${SPHINX_VERSION}-release.tar.gz &&\
    cd percona-server-${PERCONA_VERSION}* && mkdir storage/sphinx/ &&\
    cp ../sphinx-${SPHINX_VERSION}-release/mysqlse/* storage/sphinx/ &&\
    sh BUILD/autorun.sh &&\
    ./configure --with-sphinx-storage-engine &&\
    cd storage/sphinx/ && make &&\
    cp ha_sphinx.so /usr/lib/mysql/plugin &&\
    cd /usr/local/src && cat percona-build.dep | xargs apt-get -y remove && rm -rf * &&\
    apt-get remove -y dpkg-dev systemtap-sdt-dev &&\
    apt-get autoremove -y 
EXPOSE 3306
COPY conf/docker.cnf /etc/mysql/conf.d/
COPY conf/mysqld_start.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/mysqld_start.sh
ENTRYPOINT ["/usr/local/bin/mysqld_start.sh"]

