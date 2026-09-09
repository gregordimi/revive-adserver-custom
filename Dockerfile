FROM php:8.2-apache

# Install dependencies and required PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    tar \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    opcache \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Download and extract Revive Adserver (stable release)
ARG REVIVE_VERSION=6.0.8
RUN curl -sSL https://download.revive-adserver.com/revive-adserver-${REVIVE_VERSION}.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html/

# Set appropriate permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/var \
    && chmod -R 775 /var/www/html/plugins \
    && chmod -R 775 /var/www/html/www/images

WORKDIR /var/www/html
EXPOSE 80