FROM php:7.1-fpm

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

# Install dependencies for common laravel extentions
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    vim \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/include/ \
    --with-freetype-dir=/usr/include

# Install  xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP-FPM and popular/laravel required extensions using the helper script
RUN docker-php-ext-install \
    mcrypt \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    zip

RUN usermod -u 1000 www-data

# Configure PHP-FPM
# RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
#     sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini && \
#     sed -i "s/display_errors = Off/display_errors = stderr/" /etc/php5/fpm/php.ini && \
#     sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php5/fpm/php.ini && \
#     sed -i "s/;opcache.enable=0/opcache.enable=0/" /etc/php5/fpm/php.ini && \
#     sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
#     sed -i '/^listen = /clisten = 9000' /etc/php5/fpm/pool.d/www.conf && \
#     sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php5/fpm/pool.d/www.conf && \
#     sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php5/fpm/pool.d/www.conf && \
#     sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /etc/php5/fpm/pool.d/www.conf
ADD ./config/laravel.php.ini /usr/local/etc/php/conf.d
ADD ./config/laravel.pool.conf /usr/local/etc/php-fpm.d/

RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 9000

CMD ["php-fpm"]

