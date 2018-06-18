#!/bin/bash 

# run cassandra and forward port 9042
sudo docker run -d -p 9042:9042 cassandra 
