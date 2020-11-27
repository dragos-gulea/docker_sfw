FROM phusion/baseimage:latest-amd64

RUN DEBIAN_FRONTEND=noninteractive

RUN locale-gen en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

################################################################################

# Add a default non-root user to prevent root permissions issue on linux based host machine.

USER root

ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupadd -g ${PGID} sfw && \
    useradd -u ${PUID} -g sfw -m sfw -G docker_env && \
    usermod -p "*" sfw -s /bin/bash

################################################################################

# Set container timezone

USER root

ARG TIMEZONE=UTC
ENV TIMEZONE ${TIMEZONE}

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE > /etc/timezone

################################################################################

USER root

ARG DOCKER_PHP_VERSION

# Always update, install and clean when new source is added
# Always update before install or upgrade

RUN apt-get update -yqq && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        pkg-config \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        libsqlite3-dev \
        sqlite3 \
        mysql-client \
        postgresql-client \
        libssh2-1-dev && \
        apt-get clean

RUN apt-get update -yqq && \
    apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        php${DOCKER_PHP_VERSION}-cli \
        php${DOCKER_PHP_VERSION}-common \
        php${DOCKER_PHP_VERSION}-curl \
        php${DOCKER_PHP_VERSION}-intl \
        php${DOCKER_PHP_VERSION}-json \
        php${DOCKER_PHP_VERSION}-xml \
        php${DOCKER_PHP_VERSION}-mbstring \
        php${DOCKER_PHP_VERSION}-mysql \
        php${DOCKER_PHP_VERSION}-pgsql \
        php${DOCKER_PHP_VERSION}-zip \
        php${DOCKER_PHP_VERSION}-bcmath \
        php${DOCKER_PHP_VERSION}-memcached \
        php${DOCKER_PHP_VERSION}-gd \
        php${DOCKER_PHP_VERSION}-dev \
        php${DOCKER_PHP_VERSION}-soap \
        php${DOCKER_PHP_VERSION}-ssh2 \
        libxrender1 libfontconfig1 libxext6 && \
        apt-get clean

RUN pecl channel-update pecl.php.net

################################################################################

USER root

# Install Python PIP

RUN apt-get update -yqq && \
    apt-get install -y python python-pip python-dev build-essential

RUN python -m pip install --upgrade pip && \
    python -m pip install --upgrade virtualenv;

################################################################################

USER root

RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
COPY ./composer.json /home/sfw/.composer/composer.json
RUN chown -R sfw:sfw /home/sfw/.composer

USER sfw

RUN composer global install

################################################################################

USER root

ARG DOCKER_PHP_VERSION

RUN apt-get update && apt-get install -y php${DOCKER_PHP_VERSION}-xdebug && \
    sed -i 's/^;//g' /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/20-xdebug.ini

COPY ./xdebug.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini

#RUN sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
#    sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
#    sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini

################################################################################

# Check PHP version

USER root

RUN php -v | head -n 1 | grep -q "PHP ${DOCKER_PHP_VERSION}."

################################################################################

# Installing remaining dev tools

USER root

RUN apt-get update && \
    apt-get install -y --allow-downgrades --allow-remove-essential \
        git curl mc vim nano htop

################################################################################

USER root

COPY crontab /etc/cron.d/sfw
RUN chmod 0644 /etc/cron.d/sfw && \
    crontab -u root /etc/cron.d/sfw && \
    touch /var/log/working-hours.log

# Install localstak (for aws s3)

RUN pip install awscli && \
    aws configure set aws_access_key_id WS3KEY && \
    aws configure set aws_secret_access_key Ws3Secret && \
    aws configure set region us-west-2


# Installing redis
USER root
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

WORKDIR /var/www

CMD [ "api-run" ]
