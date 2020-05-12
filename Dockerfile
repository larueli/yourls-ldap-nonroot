FROM php:7.4-apache

# install the PHP extensions we need
RUN apt-get update && apt-get install -y dos2unix libldap2-dev libcap2-bin git && apt-get autoremove -y && set -eux && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install -j "$(nproc)" opcache pdo_mysql mysqli ldap && \
#
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
    echo 'opcache.memory_consumption=128' > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.interned_strings_buffer=8' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.max_accelerated_files=4000' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.revalidate_freq=60' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    a2enmod rewrite expires

ENV YOURLS_VERSION 1.7.9
ENV YOURLS_SHA256 0D9106B2936289D2FE5D4D6C017A77F96C79F4B2CACF1B59A0837D0032CA96D7

RUN set -eux && \
    curl -o yourls.tar.gz -fsSL "https://github.com/YOURLS/YOURLS/archive/${YOURLS_VERSION}.tar.gz" && \
    echo $YOURLS_SHA256 *yourls.tar.gz && \
    tar -xf yourls.tar.gz -C /var/www && \
    rm -r /var/www/html && mv "/var/www/YOURLS-${YOURLS_VERSION}" /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/ 
COPY config-docker.php /var/www/html/user/
COPY .htaccess /var/www/html/
COPY index.php /var/www/html/index.php

RUN git clone https://github.com/k3a/yourls-ldap-plugin.git && mv yourls-ldap-plugin /var/www/html/user/plugins/yourls-ldap-plugin && \
    #git clone https://github.com/ozh/yourls-fallback-url.git && mv yourls-fallback-url /var/www/html/user/plugins/yourls-fallback-url && \
    chown -R www-data:root /var/www/html && chmod -R g=rwx /var/www/html && setcap CAP_NET_BIND_SERVICE=+eip $(which apache2) && \
    dos2unix /usr/local/bin/docker-entrypoint.sh && dos2unix /var/www/html/user/config-docker.php && dos2unix /var/www/html/.htaccess && chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]