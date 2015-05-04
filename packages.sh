#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# this forces dpkg not to call sync() after package extraction and speeds up install
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
# we don't need an apt cache in a container
echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A &&\
    echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list &&\
    echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list

apt-get update && \
    apt-get --no-install-recommends -yq install \
    dpkg-dev\
    systemtap-sdt-dev\
    percona-server-server-${PERCONA_VERSION}\
    percona-server-client-${PERCONA_VERSION} &&\
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
    apt-get autoremove -y  &&\
    rm -rf /var/lib/apt/lists/*

# Cleanup
apt-get clean
rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
find /tmp /var/tmp -mindepth 2 -delete
