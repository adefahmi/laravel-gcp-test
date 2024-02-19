FROM composer:2.7 as build
WORKDIR /app
COPY . /app
RUN composer install

# php 8.2
FROM php:8.2-apache
RUN docker-php-ext-install pdo pdo_mysql

EXPOSE 8080
COPY --from=build /app /var/www/
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY .env.example /var/www/.env

RUN echo "Listen 8080" >> /etc/apache2/ports.conf && \
    a2enmod rewrite

# command artisan
RUN php /var/www/artisan key:generate

# laravel log permission denied fix
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap /var/www/vendor
RUN chmod -R 775 /var/www/storage /var/www/bootstrap /var/www/vendor
