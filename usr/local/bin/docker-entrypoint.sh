#!/usr/bin/env bash
set -e

function activateSupervisordMariaDB {
  sed s/autostart=false/autostart=true/ -i /etc/supervisord.d/mariadb.ini
  mysql -u root -e 'CREATE DATABASE wordpress;';
}

DOCKER_ENV=${DOCKER_ENV:-localdev}
MARIADB_DIR=${MARIADB_DIR:-"/var/lib/mysql/"}


if [ ${DOCKER_ENV} == "localdev" ]; then
  if [ -d ${MARIADB_DIR} ]; then
    mysql_install_db --skip-test-db --user=mysql
    activateSupervisordMariaDB
    if [ -z "$(ls -A ${MARIADB_DIR})" ]; then
      mysql_install_db --skip-test-db --user=mysql
      activateSupervisordMariaDB
    fi
  fi
else
  echo "Not a local development environment, not setting-up MariaDB."
fi

exec "$@"