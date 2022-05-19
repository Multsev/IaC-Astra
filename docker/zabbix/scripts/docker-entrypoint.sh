#!/bin/bash

# Definition
PG_VERSION="13"

ZBX_DBUSER="${ZBX_DBUSER:=zabbix}"
ZBX_DBPASS="${ZBX_DBPASS:=zabbix}"
ZBX_DBNAME="${ZBX_DBNAME:=zabbix}"

ZBX_DB_CREATE_COMMAND="
  CREATE USER $ZBX_DBUSER PASSWORD '$ZBX_DBPASS';
  CREATE DATABASE $ZBX_DBNAME WITH OWNER=$ZBX_DBUSER;
  GRANT ALL PRIVILEGES ON DATABASE $ZBX_DBNAME to $ZBX_DBUSER;
"

create_zbx_db() {
  sed -i -e "s/^local.*all.*all.*peer/local all all trust/g" /etc/postgresql/$PG_VERSION/main/pg_hba.conf

  # Run Postgres
  etc/init.d/postgresql start

  if $(gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw $ZBX_DBNAME); then
    echo "Database already exist!"
    /etc/init.d/postgresql stop
  else
    # Prepate Zabbix database
    echo $ZBX_DB_CREATE_COMMAND | gosu postgres psql && \
    zcat /tmp/create_zbx_db.sql.gz | gosu postgres psql -U zabbix -d zabbix
    sed -i "s/^# DBPassword=/DBPassword=/g" /etc/zabbix/zabbix_server.conf
    sed -i -e "s/DBName=.*/DBName=$ZBX_DBNAME/g" /etc/zabbix/zabbix_server.conf
    sed -i -e "s/DBUser=.*/DBUser=$ZBX_DBUSER/g" /etc/zabbix/zabbix_server.conf
    sed -i -e "s/DBPassword=.*/DBPassword=$ZBX_DBPASS/g" /etc/zabbix/zabbix_server.conf
  fi

  # Stop Postgres
  /etc/init.d/postgresql stop
}

# Start
create_zbx_db && /usr/bin/supervisord