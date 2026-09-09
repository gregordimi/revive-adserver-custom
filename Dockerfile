FROM php:8.2-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    tar \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    opcache \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

# Copy and extract the local archive directly
COPY revive-adserver-6.0.8.tar.gz /tmp/revive.tar.gz
RUN mkdir -p /var/www/html \
    && tar -xzf /tmp/revive.tar.gz --strip-components=1 -C /var/www/html \
    && rm -f /tmp/revive.tar.gz

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/var \
    && chmod -R 775 /var/www/html/plugins \
    && chmod -R 775 /var/www/html/www/images

WORKDIR /var/www/html
EXPOSE 80