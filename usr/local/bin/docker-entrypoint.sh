#!/usr/bin/env bash
set -e

function installWordpressLocalDev {

  wp-cli config create  --dbname=wordpress \
  --dbuser=root
  wp-cli core install --url=localhost \
    --title=Example \
    --admin_user=admin \
    --admin_email=info@example.com \
    --admin_password="admin" \
    --skip-email
  wp-cli theme activate magazine_2ndlayer_eu
}

function activateSupervisordMariaDB {
  if /usr/bin/supervisord -c /etc/supervisord.conf; then
    echo "SupervisorD started!"
  else
    echo "SupervisorD start failed!"
  fi
  supervisorctl stop nginx
  supervisorctl stop php-fpm
  supervisorctl start mariadb
  sed s/autostart=false/autostart=true/ -i /etc/supervisord.d/mariadb.ini
  mysql -u root -e 'CREATE DATABASE wordpress;';
  installWordpressLocalDev
  kill $(cat /var/run/mariadb/mariadb.pid)
  supervisorctl stop mariadb
  supervisorctl shutdown
  sleep 10
}

DOCKER_ENV=${DOCKER_ENV:-localdev}
MARIADB_DIR=${MARIADB_DIR:-"/var/lib/mysql/"}


if [ ${DOCKER_ENV} == "localdev" ]; then
  if [ -d ${MARIADB_DIR} ]; then
    if [ -z "$(ls -A ${MARIADB_DIR})" ]; then
      mysql_install_db --skip-test-db --user=mysql
      activateSupervisordMariaDB
    fi
  fi
else
  echo "Not a local development environment, not setting-up MariaDB."
fi

exec "$@"