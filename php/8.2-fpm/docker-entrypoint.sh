#!/bin/sh
set -e

sudo chown -R app:app /var/www
sudo /usr/sbin/sshd

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
