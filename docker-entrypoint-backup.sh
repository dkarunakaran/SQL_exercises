#!/bin/bash
# 
# Multi architecture MySQL docker image
# Copyright 2021 Jamiel Sharief
#

DATADIR='/var/lib/mysql';

initialize() {

  MYSQL_ROOT_PASSWORD="Foo1!"

  echo "> Initializing database"
  mkdir -p /var/lib/mysql
  chown -R mysql:mysql /var/lib/mysql

  mysqld --initialize-insecure --user=mysql

  # Start temporary server
  echo "> Starting temporary server";
  if ! mysqld --daemonize --skip-networking --user=mysql; then
    echo "Error starting mysqld"
    exit 1
  fi
  
  echo "> Setting root password";

  mysql <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
  FLUSH PRIVILEGES;
EOF

  # work similar to official mysql docker image
  if [ -n "$MYSQL_DATABASE" ]; then
   echo "> Creating database $MYSQL_DATABASE";
     mysql -p"$MYSQL_ROOT_PASSWORD" <<< "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;";
  fi

  if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
		echo "> Creating user";
    echo 
    echo "User: $MYSQL_USER"
    echo "Password: $MYSQL_PASSWORD"
    echo 

    mysql -p"$MYSQL_ROOT_PASSWORD" <<< "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"

    echo "> Granting permissions";
		if [ -n "$MYSQL_DATABASE" ]; then
         mysql -p"$MYSQL_ROOT_PASSWORD" <<< "GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';";
		fi
	fi

  # Shutdown temporary server
  echo "> Shutting down temporary server";
  if ! mysqladmin shutdown -uroot -p"$MYSQL_ROOT_PASSWORD"  ; then
      echo "Error shutting down mysqld"
      exit 1
  fi
  echo "> Complete";
}

# Initialize if needed
if [ "$1" = 'mysqld' ]; then
  if [ ! -d "$DATADIR/mysql" ]; then
    initialize;
  fi
fi

cat <<EOF

    __  ___      _____ ____    __ 
   /  |/  /_  __/ ___// __ \  / / 
  / /|_/ / / / /\__ \/ / / / / /  
 / /  / / /_/ /___/ / /_/ / / /___
/_/  /_/\__, //____/\___\_\/_____/
       /____/                     

EOF
if [ "$1" = 'mysqld' ]; then
  exec "$@" "--user=mysql"
else
  exec "$@"
fi