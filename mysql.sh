#/bin/sh
docker exec -i -t `docker ps -f images=tyjak/percona-sphinxse -q` mysql
