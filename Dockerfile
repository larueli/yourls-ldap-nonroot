FROM php:7.2-apache

# install the PHP extensions we need
RUN apt-get update && apt-get install -y dos2unix libcap2-bin git && apt-get autoremove -y && set -eux && \
    docker-php-ext-install -j "$(nproc)" opcache pdo_mysql mysqli && \
#
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
    echo 'opcache.memory_consumption=128' > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.interned_strings_buffer=8' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.max_accelerated_files=4000' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.revalidate_freq=60' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    a2enmod rewrite expires

ENV YOURLS_VERSION 1.7.6
ENV YOURLS_SHA256 f3623af6e4cabee61a39d3deca3c941717c5e0a60bc288b6f3a668f87a20ae2e
RUN set -eux && \
    curl -o yourls.tar.gz -fsSL "https://github.com/YOURLS/YOURLS/archive/${YOURLS_VERSION}.tar.gz" && \
    echo "$YOURLS_SHA256 *yourls.tar.gz" | sha256sum -c - && \
# upstream tarballs include ./YOURLS-${YOURLS_VERSION}/ so this gives us /usr/src/YOURLS-${YOURLS_VERSION}
    tar -xf yourls.tar.gz -C /var/www && \
# move back to a common /usr/src/yourls
    mv "/var/www/YOURLS-${YOURLS_VERSION}" /var/www/html && \
    rm yourls.tar.gz

COPY docker-entrypoint.sh /usr/local/bin/ 
COPY config-docker.php /var/www/html/user/
COPY .htaccess /var/www/html/

RUN mkdir /var/www/html/plugins && \
    git clone https://github.com/k3a/yourls-ldap-plugin.git && mv yourls-ldap-plugin /var/www/html/plugins/yourls-ldap-plugin && \
    chown -R www-data:root /var/www/html && chmod -R g=rwx /var/www/html && setcap CAP_NET_BIND_SERVICE=+eip $(which apache2-foreground) && \
    dos2unix /usr/local/bin/docker-entrypoint.sh && dos2unix /var/www/html/user/config-docker.php && dos2unix /var/www/html/.htaccess && chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]