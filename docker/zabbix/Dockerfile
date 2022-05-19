FROM debian:bullseye-slim
LABEL maintainer "Maksim Multsev"

#TO DO
# Установка компонента с точностью до версии: apt-get install cowsay=3.03+dfsg1-6

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y wget dialog apt-utils gosu && \
    wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb && \
    dpkg -i zabbix-release_6.0-1+debian11_all.deb && \
    apt-get update -y && \
    rm -f zabbix-release_6.0-1+debian11_all.deb

RUN apt-get install -y  \
    postgresql postgresql-contrib \
    nginx \
    zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent \
    supervisor

RUN sed -i -e "s/# en_US.UTF-8 UTF-8.*/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    sed -i -e "s/# ru_RU.UTF-8 UTF-8.*/ru_RU.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen

COPY ./scripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY ./conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./conf/zabbix-nginx.conf /etc/nginx/conf.d/zabbix.conf

COPY ./sql/create_zbx_db.sql.gz /tmp/create_zbx_db.sql.gz

RUN addgroup --system --quiet zabbix && \
    adduser --quiet --system --disabled-login --ingroup zabbix --home /var/lib/zabbix --no-create-home zabbix && \
    mkdir -m u=rwx,g=rwx,o= -p /var/lib/zabbix && \
    chown zabbix:zabbix /var/lib/zabbix

RUN rm -fr /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/conf.d/zabbix.conf /etc/nginx/sites-enabled/default && \
    mkdir /run/php && \
    chmod +x /usr/bin/docker-entrypoint.sh

VOLUME ["/var/lib/postgresql/13/main/base"]

EXPOSE 80/tcp 10050/tcp 10051/tcp 5432/tcp

CMD [ "/usr/bin/docker-entrypoint.sh" ]