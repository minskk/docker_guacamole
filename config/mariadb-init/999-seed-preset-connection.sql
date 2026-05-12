-- Предустановленное подключение в каталоге Guacamole (MariaDB init, после 001/002).
-- Важно: Guacamole не умеет тип соединения «HTTP» для Odoo (порт 8069). В списке создаётся
-- SSH к тому же хосту — откройте в браузере http://82.209.227.116:8069/ отдельно или смените
-- протокол/порт в Settings → Connections после входа как guacadmin.
-- Схема: https://guacamole.apache.org/doc/gug/jdbc-auth-schema.html

-- Группа ROOT обычно появляется при первом старте веб-приложения; для сида создаём заранее.
INSERT INTO guacamole_connection_group (
    parent_id,
    connection_group_name,
    type,
    max_connections,
    max_connections_per_user,
    enable_session_affinity
)
SELECT NULL, 'ROOT', 'ORGANIZATIONAL', NULL, NULL, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM guacamole_connection_group
    WHERE connection_group_name = 'ROOT' AND parent_id IS NULL
);

SET @root_gid = (
    SELECT connection_group_id FROM guacamole_connection_group
    WHERE connection_group_name = 'ROOT' AND parent_id IS NULL
    LIMIT 1
);

INSERT INTO guacamole_connection (connection_name, parent_id, protocol)
SELECT '82.209.227.116 (SSH, Odoo web :8069)', @root_gid, 'ssh'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM guacamole_connection
    WHERE connection_name = '82.209.227.116 (SSH, Odoo web :8069)'
      AND parent_id <=> @root_gid
);

SET @conn_id = (
    SELECT connection_id FROM guacamole_connection
    WHERE connection_name = '82.209.227.116 (SSH, Odoo web :8069)'
      AND parent_id <=> @root_gid
    LIMIT 1
);

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT @conn_id, 'hostname', '82.209.227.116'
FROM DUAL
WHERE @conn_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM guacamole_connection_parameter
    WHERE connection_id = @conn_id AND parameter_name = 'hostname'
);

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT @conn_id, 'port', '22'
FROM DUAL
WHERE @conn_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM guacamole_connection_parameter
    WHERE connection_id = @conn_id AND parameter_name = 'port'
);

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT @conn_id, 'username', 'CHANGE_ME'
FROM DUAL
WHERE @conn_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM guacamole_connection_parameter
    WHERE connection_id = @conn_id AND parameter_name = 'username'
);

INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
SELECT e.entity_id, @conn_id, perm.p
FROM guacamole_entity e
CROSS JOIN (
    SELECT 'READ' AS p
    UNION ALL SELECT 'UPDATE'
    UNION ALL SELECT 'ADMINISTER'
) AS perm
WHERE @conn_id IS NOT NULL
  AND e.name = 'guacadmin'
  AND e.type = 'USER'
  AND NOT EXISTS (
    SELECT 1 FROM guacamole_connection_permission x
    WHERE x.entity_id = e.entity_id
      AND x.connection_id = @conn_id
      AND x.permission = perm.p
);
