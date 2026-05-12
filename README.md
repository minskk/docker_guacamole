# docker_guacamole

## Установка

```bash
git clone git@github.com:minskk/docker_guacamole.git
cd docker_guacamole
docker compose up -d
```

## посмотреть пароль 
```bash
docker compose -f /home/user/projects/docker_guacamole/docker-compose.yml config | grep -A2 mariadb
```

```bash
docker compose -f /home/user/projects/docker_guacamole/docker-compose.yml config | grep -E 'MARIADB_USER|MARIADB_PASSWORD|MYSQL_USERNAME|MYSQL_PASSWORD'
```

      MYSQL_PASSWORD: changeme_guac
      MYSQL_USERNAME: guacamole_user
      MARIADB_PASSWORD: changeme_guac
      MARIADB_USER: guacamole_user


## перезапустить веб-приложение:

```bash
docker compose restart guacamole
```