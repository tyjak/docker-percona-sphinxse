FROM phusion/baseimage:latest
MAINTAINER David Foucner <dev@tyjak.net>

ENV PERCONA_VERSION=5.5 SPHINX_VERSION=2.2.9
WORKDIR /usr/local/src

ADD http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-release.tar.gz sphinx-${SPHINX_VERSION}-release.tar.gz
COPY ./packages.sh /build/packages.sh
RUN /build/packages.sh


COPY ./mysql /build/mysql
RUN /build/mysql/setup.sh

#COPY conf/docker.cnf /etc/mysql/conf.d/
#COPY conf/mysqld_start.sh /usr/local/bin/

EXPOSE 3306
WORKDIR /usr/lib/mysql
CMD ["/sbin/my_init"]

#RUN chmod a+x /usr/local/bin/mysqld_start.sh
#ENTRYPOINT ["/usr/local/bin/mysqld_start.sh"]

