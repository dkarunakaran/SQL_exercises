# 
# Multi architecture MySQL docker image
# Copyright 2021 Jamiel Sharief
#
#FROM ubuntu:20.04
FROM jupyter/minimal-notebook:x86_64-ubuntu-20.04


ENV DATE_TIMEZONE UTC
ENV DEBIAN_FRONTEND=noninteractive

#RUN groupadd -r mysql && useradd -r -g mysql mysql

# Try to fix failures  ERROR: executor failed running [
ENV DOCKER_BUILDKIT=03

ENV COMPOSE_DOCKER_CLI_BUILD=0

USER root

RUN apt-get update && apt-get install -y \
    mysql-server \
    mysql-client \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
	&& chmod 1777 /var/lib/mysql /var/run/mysqld 

VOLUME /var/lib/mysql

COPY ./1-sakila-schema.sql /step_1.sql
COPY ./2-sakila-data.sql /step_2.sql

COPY config/ /etc/mysql/
COPY docker-entrypoint.sh /entrypoint.sh

RUN pip install --upgrade pip

RUN pip install numpy

RUN pip install pandas

RUN pip install mysql-connector-python

CMD ["su", "-" ,"groupadd", "-r", "mysql"]

CMD ["su", "-" ,"useradd", "-r", "-g", "mysql", "mysql"]

RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306 33060

EXPOSE 8888 8888

CMD ["mysqld"]