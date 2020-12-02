ARG DOCKER_PHP_VERSION

FROM php:${DOCKER_PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND noninteractive

USER root

RUN set -xe;

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install gd

RUN apt-get update -yqq && \
    apt-get install -y apt-utils && \
    pecl channel-update pecl.php.net

################################################################################

#RUN apt-get install libzip-dev -y && \
#    docker-php-ext-configure zip --with-libzip && \
#    docker-php-ext-install exif;

RUN docker-php-ext-install exif;

RUN docker-php-ext-install opcache;

COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

ARG ENV="prod"
RUN if [ ${ENV} = "dev" ]; then \
    echo "opcache.enable=\"0\"" >> /usr/local/etc/php/conf.d/opcache.ini \
;fi

################################################################################

RUN apt-get install libyaml-dev -y ; \
    pecl install yaml ; \
    docker-php-ext-enable yaml;

RUN apt-get install -y libxml2-dev libxrender1 libfontconfig1 libxext6 && \
    docker-php-ext-install soap

################################################################################

#RUN if [ ${ENV} = "dev" ]; then \
#	    pecl install xdebug; \
#	    docker-php-ext-enable xdebug; \
#	fi ;

################################################################################

# Installing redis
USER root

RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

RUN usermod -u 1000 www-data

USER www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
