Percona 5.5 with sphinx storage engine
--------------------------------------

This is a work in progress.

* To have percona running :
<pre>sudo docker run -d -p 3306:3306 tyjak/percona-sphinxse:v1</pre>

* To launch lysql client
<pre>sudo docker exec -i -t {name} /usr/bin/mysql -uadmin -h localhost</pre>

