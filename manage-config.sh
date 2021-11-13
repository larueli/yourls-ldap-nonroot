#!/bin/bash
# if not specified, let's generate a random value
: "${YOURLS_COOKIEKEY:=$(head -c1m /dev/urandom | sha1sum | cut -d' ' -f1)}"

# We want to copy the initial config if the actual config file doesn't already
# exist OR if it is an empty file (e.g. it has been created for the volume mount).
if [ ! -e /var/www/html/user/config.php ] || [ ! -s /var/www/html/user/config.php ]; then
    cp /var/www/html/user/config-docker.php /var/www/html/user/config.php
fi

: "${YOURLS_USER:=}"
: "${YOURLS_PASS:=}"
if [ -n "${YOURLS_USER}" ] && [ -n "${YOURLS_PASS}" ]; then
	result=$(sed "s/  getenv('YOURLS_USER') => getenv('YOURLS_PASS'),/  \'${YOURLS_USER}\' => \'${YOURLS_PASS}\',/g" /var/www/html/user/config.php)
	echo "$result" > /var/www/html/user/config.php
fi
