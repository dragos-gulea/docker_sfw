ARG MYSQL_VERSION=latest

FROM mysql:${MYSQL_VERSION}

################################################################################

# Set container timezone

ARG TIMEZONE=UTC
ENV TIMEZONE ${TIMEZONE}

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE > /etc/timezone

################################################################################

# Set mysql data owner

RUN chown -R mysql:root /var/lib/mysql/

################################################################################

COPY my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 0444 /etc/mysql/conf.d/my.cnf

################################################################################

#COPY docker-entrypoint.sh /usr/local/bin/
#RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
#ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mysqld"]

EXPOSE 3306
