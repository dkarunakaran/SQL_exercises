#!/bin/bash

docker run --net=host -p 3306:3306 -d sakiladb/mysql:8


docker build -t jupyter_sql .

docker run --net=host -it -p 8888:8888 -v /home/beastan/Documents/projects/sql_exercies:/home/jovyan/work jupyter_sql


