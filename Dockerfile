FROM php:8.2.1-fpm-alpine3.16

# Install dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache --virtual .build-deps linux-headers g++ make autoconf yaml-dev bash nano
RUN apk add php-gd gmp git zip unzip curl sqlite nginx supervisor \
    freetype freetype-dev \
    jpeg-dev pngquant pngcrush optipng gifsicle jpegoptim \
    php-zip curl-dev libsodium-dev libzip-dev libressl-dev \
    php81-gd php81-imap php81-redis php81-cgi php81-bcmath php81-mysqli \
    php81-zlib php81-curl php81-zip php81-mbstring php81-iconv gmp-dev \
    libpng libpng-dev libjpeg-turbo-dev libwebp-dev oniguruma-dev \
    zlib-dev libtool libxml2-dev bzip2-dev libxpm-dev gnupg gettext-dev libmcrypt-dev icu-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd exif bcmath gettext opcache intl gmp mbstring bz2 zip shmop sockets sysvmsg sysvsem sysvshm soap curl pdo pdo_mysql && \
    pecl install redis && \
    docker-php-ext-enable sodium redis zip bz2 opcache && \
    apk del .build-deps

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy PHP configuration files
COPY docker/php/php.ini /usr/local/etc/php/php.ini
COPY docker/php/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/

# Copy configuration files for Nginx and Supervisor
COPY docker/nginx/default.conf /etc/nginx/http.d/
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy project files and Composer
WORKDIR /var/www/html
COPY . .
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Composer dependencies for production
RUN composer install --ignore-platform-reqs --no-interaction --no-plugins --no-scripts --prefer-dist --optimize-autoloader --no-dev

# Set directory permissions
RUN chown -R www-data:www-data storage/ bootstrap/cache && \
    chmod -R 775 storage/ bootstrap/cache && \
    chmod -R 775 storage/logs/ && \
    chmod -R 775 storage/framework/sessions/ && \
    chmod -R 775 storage/framework/views/ && \
    chmod -R 775 storage/framework/cache

# Entrypoint
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
