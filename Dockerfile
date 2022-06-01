FROM larueli/php-base-image:8.0

ARG YOURLS_VERSION=1.9.1
ENV YOURLS_VERSION=${YOURLS_VERSION}

USER 0

RUN curl -o yourls.tar.gz -fsSL "https://github.com/YOURLS/YOURLS/archive/refs/tags/${YOURLS_VERSION}.tar.gz" && \
    tar -xf yourls.tar.gz -C /var/www && \
    rm -r /var/www/html && mv "/var/www/YOURLS-${YOURLS_VERSION}" /var/www/html

COPY manage-config.sh /docker-entrypoint-init.d/manage-config.sh
COPY config-docker.php /var/www/html/user/
COPY .htaccess /var/www/html/
COPY index.php /var/www/html/index.php

RUN git clone https://github.com/k3a/yourls-ldap-plugin.git && mv yourls-ldap-plugin /var/www/html/user/plugins/yourls-ldap-plugin && \
    git clone https://github.com/joshp23/YOURLS-AuthMgrPlus.git && mv YOURLS-AuthMgrPlus/authMgrPlus /var/www/html/user/plugins/authMgrPlus && \
    chgrp -R root /var/www/html && chmod -R g=rwx /var/www/html && chmod -R +x /docker-entrypoint-init.d

USER 548752
