FROM perlur/centos-nginx-php-fpm

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "magazine_2ndlayer_eu"

RUN yum update -y && \
    yum install -y php-json php-zip php-mysqlnd mariadb-server && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

RUN curl --tlsv1.2 -o /usr/local/bin/wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp-cli

WORKDIR /var/www/default/html

USER nginx
RUN wp-cli core download --skip-content
COPY src/wordpress/ ./

USER mysql
RUN mysql_install_db

USER root

ADD etc/supervisord.d/ /etc/supervisord.d/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
