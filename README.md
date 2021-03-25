# OSSystem redmine image

## Description

This is just a little modified redmine with our themes/plugins

## How-to

1. Pull redmine image: `docker pull xaked/oss-redmine:4.1.1.3`
1. Run it: `docker run xaked/oss-redmine:4.1.1.3`

Also a test docker-compose configuration with database:

```
version: '3.8'

services:
  db:
    image: docker.io/mariadb:10.3
    env_file: .env
    volumes:
      - ${PWD}/mariadb:/var/lib/mysql

  redmine:
    image: test:latest
    # command: tail -f /dev/null
    # image: docker.io/xaked/oss-redmine:4.1.1.1
    env_file: .env
    depends_on:
      - db
    ports:
      - 8081:3000/tcp
```

Environment vars:

 - `MYSQL_ROOT_PASSWORD`: 123456
 - `MYSQL_DATABASE`: redmine
 - `MYSQL_USER`: pm
 - `MYSQL_PASSWORD`: pewpew
 - `MARIADB_EXTRA_FLAGS`: --max_allowed_packet=1073741824
 - `REDMINE_DB_DATABASE`: redmine
 - `REDMINE_DB_USERNAME`: pm
 - `REDMINE_DB_PASSWORD`: pewpew
 - `REDMINE_DB_MYSQL`: db
 - `REDMINE_PLUGINS_MIGRATE`: 1

> Maintained by mikkra (Mikhail K.) <u@xaked.com>
