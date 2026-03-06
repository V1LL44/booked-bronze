FROM php:7.4-cli

WORKDIR /app

# Extensiones necesarias para Booked (MySQL)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Ajustes PHP para produccion: ocultar warnings/deprecations en pantalla
RUN { \
  echo 'display_errors=Off'; \
  echo 'display_startup_errors=Off'; \
  echo 'log_errors=On'; \
  echo 'error_reporting=E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_WARNING'; \
} > /usr/local/etc/php/conf.d/booked-runtime.ini

COPY . /app

# Crear config.php desde dist y ajustar valores de instalacion para Render
RUN cp /app/config/config.dist.php /app/config/config.php \
  && sed -i "s#\\$conf\\['settings'\\]\\['script.url'\\] = '.*';#\\$conf['settings']['script.url'] = 'https://booked-bronze.onrender.com/';#" /app/config/config.php \
  && sed -i "s#\\$conf\\['settings'\\]\\['install.password'\\] = '.*';#\\$conf['settings']['install.password'] = 'BronzeInstall2026!';#" /app/config/config.php

# Directorios que Booked necesita con escritura durante instalacion
RUN mkdir -p /app/tpl_c /app/uploads /app/config \
  && chmod -R 777 /app/tpl_c /app/uploads /app/config

# Render inyecta PORT; fallback local 10000
# Variables opcionales para DB en Render:
# BOOKED_DB_HOST, BOOKED_DB_PORT, BOOKED_DB_NAME, BOOKED_DB_USER, BOOKED_DB_PASSWORD, BOOKED_SCRIPT_URL
CMD ["sh", "-c", "DB_HOST=$BOOKED_DB_HOST; if [ -n \"$BOOKED_DB_PORT\" ]; then DB_HOST=\"${BOOKED_DB_HOST}:${BOOKED_DB_PORT}\"; fi; if [ -n \"$BOOKED_SCRIPT_URL\" ]; then sed -i \"s#\\$conf\\['settings'\\]\\['script.url'\\] = '.*';#\\$conf['settings']['script.url'] = '$BOOKED_SCRIPT_URL';#\" /app/config/config.php; fi; if [ -n \"$BOOKED_DB_HOST\" ]; then sed -i \"s#\\$conf\\['settings'\\]\\['database'\\]\\['hostspec'\\] = '.*';#\\$conf['settings']['database']['hostspec'] = '$DB_HOST';#\" /app/config/config.php; fi; if [ -n \"$BOOKED_DB_NAME\" ]; then sed -i \"s#\\$conf\\['settings'\\]\\['database'\\]\\['name'\\] = '.*';#\\$conf['settings']['database']['name'] = '$BOOKED_DB_NAME';#\" /app/config/config.php; fi; if [ -n \"$BOOKED_DB_USER\" ]; then sed -i \"s#\\$conf\\['settings'\\]\\['database'\\]\\['user'\\] = '.*';#\\$conf['settings']['database']['user'] = '$BOOKED_DB_USER';#\" /app/config/config.php; fi; if [ -n \"$BOOKED_DB_PASSWORD\" ]; then sed -i \"s#\\$conf\\['settings'\\]\\['database'\\]\\['password'\\] = '.*';#\\$conf['settings']['database']['password'] = '$BOOKED_DB_PASSWORD';#\" /app/config/config.php; fi; cd /app/Web && php -S 0.0.0.0:${PORT:-10000} -t /app/Web"]
