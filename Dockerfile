# Image with and REST API in PHP Language in Slim framework, you can POST a URL and you will get the http code response
# Exposes prometheus metrics with prometheus_client_php with in-memory APCU storage
FROM php:8-alpine

# install APCU in-memory storage
RUN apk add \
    autoconf \
    gcc \
    build-base \
    && pecl install apcu \
    && docker-php-ext-enable apcu

# enable APCU extension for PHP
RUN echo "apc.enable_cli = On" > /usr/local/etc/php/conf.d/docker-php-ext-apcu-cli.ini

WORKDIR /var/www

# Copy REST API Code and dependencies already compiled
COPY php-app /var/www/

# Run webServer
CMD php -S 0.0.0.0:8080 -t public

# 8080 and 9095 (Here only for informative purpouses)
EXPOSE 8080
EXPOSE 9095

# Run it for testing purpouses with docker run -d -p 8080:8080 -p 8095:8080 usagre90/scraper-service