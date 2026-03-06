#!/usr/bin/env sh
set -eu

APP_PORT="${PORT:-10000}"

# Aplicar variables de entorno a config.php en runtime
if [ -n "${BOOKED_SCRIPT_URL:-}" ]; then
  sed -i "s#\$conf\['settings'\]\['script.url'\] = '.*';#\$conf['settings']['script.url'] = '${BOOKED_SCRIPT_URL}';#" /app/config/config.php
fi

if [ -n "${BOOKED_DB_HOST:-}" ]; then
  DB_HOST="${BOOKED_DB_HOST}"
  if [ -n "${BOOKED_DB_PORT:-}" ]; then
    DB_HOST="${BOOKED_DB_HOST}:${BOOKED_DB_PORT}"
  fi
  sed -i "s#\$conf\['settings'\]\['database'\]\['hostspec'\] = '.*';#\$conf['settings']['database']['hostspec'] = '${DB_HOST}';#" /app/config/config.php
fi

if [ -n "${BOOKED_DB_NAME:-}" ]; then
  sed -i "s#\$conf\['settings'\]\['database'\]\['name'\] = '.*';#\$conf['settings']['database']['name'] = '${BOOKED_DB_NAME}';#" /app/config/config.php
fi

if [ -n "${BOOKED_DB_USER:-}" ]; then
  sed -i "s#\$conf\['settings'\]\['database'\]\['user'\] = '.*';#\$conf['settings']['database']['user'] = '${BOOKED_DB_USER}';#" /app/config/config.php
fi

if [ -n "${BOOKED_DB_PASSWORD:-}" ]; then
  sed -i "s#\$conf\['settings'\]\['database'\]\['password'\] = '.*';#\$conf['settings']['database']['password'] = '${BOOKED_DB_PASSWORD}';#" /app/config/config.php
fi

cd /app/Web
exec php -S "0.0.0.0:${APP_PORT}" -t /app/Web
