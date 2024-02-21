# Use PHP 8.2 FPM Alpine as base image
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    libzip-dev \
    postgresql-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_pgsql \
        zip \
    && apk del libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libzip-dev

RUN mkdir -p /run/nginx

COPY docker/nginx.conf /etc/nginx/nginx.conf


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy application files
COPY . .

# Copy environment file
COPY .env.example .env

# Install Laravel dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

CMD sh /var/www/html/docker/startup.sh
