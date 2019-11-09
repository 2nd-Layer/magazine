FROM perlur/centos-nginx-php-fpm

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "magazine_2ndlayer_eu"

RUN yum update -y && \
    yum clean all && rm -rf /var/cache/yum

RUN curl --tlsv1.2 -o /usr/local/bin/wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp-cli

RUN chown nginx.nginx /var/www/default/html
WORKDIR /var/www/default/html

USER nginx
RUN wp-cli core download --skip-content

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
