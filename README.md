# docker_guacamole

Стек [Apache Guacamole](https://guacamole.apache.org/) 1.6.0 в Docker: **guacd**, веб-приложение на Tomcat, **MariaDB** для учётных записей и каталога подключений, опционально **Adminer** для администрирования БД.

Официальная документация по контейнерам: [Installing Guacamole with Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html).

## Состав

| Сервис | Назначение |
|--------|------------|
| `guacd` | Прокси-демон (RDP, VNC, SSH и др.) |
| `guacamole` | Веб-интерфейс |
| `mariadb` | База `guacamole_db` |
| `guacamole-schema` | Одноразовая подготовка SQL init (схема + `config/mariadb-init/*.sql`) |
| `adminer` | Веб-UI к MariaDB |

## Требования

- Docker Engine и Docker Compose v2

## Быстрый старт

```bash
git clone git@github.com:minskk/docker_guacamole.git
cd docker_guacamole
docker compose up -d
```

После старта:

- **Guacamole:** [http://127.0.0.1:8080/](http://127.0.0.1:8080/) (контекст `ROOT`, без `/guacamole/`)
- **Adminer:** [http://127.0.0.1:8081/](http://127.0.0.1:8081/) (сервер в форме: `mariadb`)

Первый вход в Guacamole: **`guacadmin`** / **`guacadmin`**. Сразу смените пароль в настройках.

## Переменные окружения (`.env`)

| Переменная | Назначение | Значение по умолчанию |
|------------|------------|------------------------|
| `GUAC_DB_PASSWORD` | Пароль пользователя БД `guacamole_user` и веб-приложения Guacamole | `changeme_guac` |
| `MARIADB_ROOT_PASSWORD` | Пароль root MariaDB | `changeme_root` |

Пример `.env`:

```env
GUAC_DB_PASSWORD=сложный_секрет
MARIADB_ROOT_PASSWORD=другой_секрет
```

## Пароли и проверка конфигурации

Подставленные значения смотрите так:

```bash
docker compose config | grep -E 'MARIADB_USER|MARIADB_PASSWORD|MYSQL_USERNAME|MYSQL_PASSWORD'
```

Пароль приложения к БД совпадает с **`GUAC_DB_PASSWORD`** (или дефолт **`changeme_guac`**, если переменная не задана).

Скрипты в `docker-entrypoint-initdb.d` выполняются **только при первом создании** тома `mariadb-data`. Если том уже был создан с другим паролем, смена строк в compose **не обновит** пароль внутри MariaDB — нужен сброс тома или ручное изменение пользователя в БД.

## Перезапуск веб-приложения

После смены файлов в `config/` (в т.ч. JAR брендинга):

```bash
docker compose restart guacamole
```

## Каталог `config/`

| Путь | Назначение |
|------|------------|
| `config/user-mapping.xml` | Шаблон для встроенного файлового провайдера (при JDBC основная аутентификация — в БД; см. [документацию](https://guacamole.apache.org/doc/gug/configuring-guacamole.html#user-mapping-xml)) |
| `config/extensions/*.jar` | Расширения (в т.ч. собранный брендинг) |
| `config/mariadb-init/*.sql` | Дополнительные SQL при **первой** инициализации БД (например `999-seed-preset-connection.sql`) |

`GUACAMOLE_HOME` в контейнере указывает на смонтированный `./config` (шаблон копируется при старте образа).

## Брендинг (логин, стили, переводы)

Исходники: каталог **`branding/`** (manifest, CSS, HTML-патчи, переводы, изображения).

Сборка JAR в `config/extensions/`:

```bash
./scripts/build-branding-jar.sh
docker compose restart guacamole
```

Подробности: [guacamole-ext](https://guacamole.apache.org/doc/gug/guacamole-ext.html).

## Предустановленное подключение в каталоге

Файл **`config/mariadb-init/999-seed-preset-connection.sql`** добавляет запись в БД при **первом** поднятии MariaDB (вместе со схемой Guacamole). Guacamole не открывает произвольные HTTP-сайты как сессию; в сиде по умолчанию задаётся **SSH** к хосту из скрипта — при необходимости отредактируйте SQL или подключение в веб-админке.

## Полный сброс данных

Удалит БД и повторно применит init-скрипты:

```bash
docker compose down
docker volume rm docker_guacamole_mariadb-data docker_guacamole_guacamole-initdb 2>/dev/null
docker compose up -d
```

Имена томов проверьте: `docker volume ls | grep docker_guacamole`.

## Безопасность

- Не оставляйте дефолтные пароли и Adminer без ограничения доступа в production.
- Ограничьте порты **8080** / **8081** файрволом или VPN.

## Ссылки

- [Guacamole Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html)
- [MariaDB / MySQL schema](https://guacamole.apache.org/doc/gug/mysql-auth.html)
- [Adminer (Docker Hub)](https://hub.docker.com/_/adminer)
