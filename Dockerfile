# syntax=docker/dockerfile:1

FROM php:8.2.35-fpm-alpine3.23

ARG VERSION=dev

LABEL org.opencontainers.image.title="myphp82" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/baiyamao/myphp82" \
      org.opencontainers.image.base.name="docker.io/library/php:8.2.35-fpm-alpine3.23"

WORKDIR /app

# Keep the tooling and system libraries from the original image.
RUN set -eux; \
    apk add --no-cache \
        git \
        curl \
        libpng-dev \
        oniguruma-dev \
        libxml2-dev \
        libzip-dev \
        zip \
        unzip \
        nodejs \
        npm \
        build-base \
        python3 \
        py3-pip; \
    ln -sf /usr/bin/python3 /usr/bin/python

RUN docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        exif \
        pcntl \
        bcmath \
        gd \
        opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

EXPOSE 9000

CMD ["php-fpm"]
