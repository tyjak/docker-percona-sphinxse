#/bin/bash
if [ -f Dockerfile ]; then
    if [ ! -d `pwd`/data/mysql ]; then
        mkdir -p `pwd`/data/mysql
    fi
    docker run --name=mysql -d -P -v `pwd`/data/mysql:/var/lib/mysql tyjak/percona-sphinxse
fi
