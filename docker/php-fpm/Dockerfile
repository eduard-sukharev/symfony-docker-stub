FROM php:8.2-fpm-bullseye AS base

RUN apt update \
    && apt install -y git unzip  \
    libcurl4-openssl-dev libpq-dev libz-dev libicu-dev libonig-dev

RUN docker-php-ext-install -j$(nproc) curl pdo pgsql pdo_pgsql dba intl mbstring

RUN pecl install xdebug-3.2.2 \
    && pecl install redis \
    && docker-php-ext-enable xdebug redis

ARG SYMFONY_CLI_VERSION=5.10.2
RUN curl -sSLk https://get.symfony.com/cli/installer | bash
COPY symfony.ini /usr/local/etc/php/conf.d/
COPY www.conf /usr/local/etc/php-fpm.d/
COPY zz-docker.conf /usr/local/etc/php-fpm.d/

RUN ln -s /usr/local/bin/php /usr/bin/php

ARG PROJECT_DIR=/app
RUN mkdir -p $PROJECT_DIR

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR $PROJECT_DIR

# RUN mkdir /var/www/.ssh && \
#    echo "Host private.gitlab.repo\n\tStrictHostKeyChecking no\n" > /var/www/.ssh/config

FROM base AS dev

RUN chown -R www-data:www-data $PROJECT_DIR
RUN chown -R www-data:www-data /var/www

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupmod -g $GROUP_ID www-data
RUN usermod -u $USER_ID -g $GROUP_ID www-data

USER www-data
