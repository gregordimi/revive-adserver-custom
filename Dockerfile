FROM php:8.2-apache

# Install dependencies and required PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    tar \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    opcache \
    intl \
    && rm -rf /var/lib/apt/lists/*

# Suppress Apache ServerName warning and enable mod_rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite

# Optimize PHP settings for Revive Adserver
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/revive.ini \
    && echo "upload_max_filesize = 32M" >> /usr/local/etc/php/conf.d/revive.ini \
    && echo "post_max_size = 32M" >> /usr/local/etc/php/conf.d/revive.ini

# Copy and extract the local tarball
COPY revive-adserver-6.0.8.tar.gz /tmp/revive.tar.gz
RUN mkdir -p /var/www/html \
    && tar -xzf /tmp/revive.tar.gz --strip-components=1 -C /var/www/html \
    && rm -f /tmp/revive.tar.gz

# Set directory permissions required by Revive
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/var \
    && chmod -R 775 /var/www/html/plugins \
    && chmod -R 775 /var/www/html/www/images

WORKDIR /var/www/html
EXPOSE 80