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
CMD ["sh", "-c", "cd /app/Web && php -S 0.0.0.0:${PORT:-10000} -t /app/Web"]
