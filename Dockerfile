FROM php:8.2-fpm-alpine AS base

RUN apk add --no-cache \
    nodejs \
    npm \
    postgresql-client \
    && npm install -g npm@latest

RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    oniguruma-dev \
    postgresql-dev \
    sqlite-dev \
    icu-dev \
    libexif-dev \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    zip \
    gd \
    intl \
    opcache \
    bcmath \
    exif

