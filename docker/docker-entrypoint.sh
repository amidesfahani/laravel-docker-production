#!/bin/sh

# Move to application directory
cd /var/www/html

# Clear the old boostrap/cache/compiled.php
php artisan clear-compiled

# Recreate boostrap/cache/compiled.php
php artisan optimize

# Start Supervisord to manage php-fpm, nginx, and queue workers
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
