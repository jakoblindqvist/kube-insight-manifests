#!/bin/bas
# run kairosdb and forward port 8080
sudo docker run -d -p 8080:8080 --net=host -e CASSANDRA_HOSTS=localhost -e CASSANDRA_PORT=9042 elastisys/kairosdb:1.2.1 
